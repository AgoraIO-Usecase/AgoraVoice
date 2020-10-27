package io.agora.education.impl.cmd

import io.agora.education.impl.util.Convert
import io.agora.education.api.room.EduRoom
import io.agora.education.api.room.data.RoomType
import io.agora.education.api.stream.data.EduStreamEvent
import io.agora.education.api.user.data.EduBaseUserInfo
import io.agora.education.api.user.data.EduUserEvent
import io.agora.education.api.user.data.EduUserInfo
import io.agora.education.impl.room.data.response.EduFromUserRes
import io.agora.education.impl.room.data.response.EduUserRes
import io.agora.education.impl.user.data.EduUserInfoImpl
import io.agora.rte.RteEngineImpl

internal open class CMDProcessor {
    companion object {
        const val TAG = "CMDProcessor"

        /**调用此函数之前须确保first和second代表的是同一个用户
         * 比较first的数据是否比second的更为接近当前时间(即找出一个最新数据)
         * @return > 0（user > old）
         *         !(> 0) user <= old*/
        internal fun compareUserInfoTime(first: EduUserInfo, second: EduUserInfo): Long {
            /**判断更新时间是否为空(为空的有可能是原始数据)*/
            if ((first as EduUserInfoImpl).updateTime == null) {
                return -1
            }
            if ((second as EduUserInfoImpl).updateTime == null) {
                return first.updateTime!!
            }
            /**最终判断出最新数据*/
            return first.updateTime!!.minus(second.updateTime!!)
        }

        /**operator有可能为空(说明用户自己就是操作者)，我们需要把当前用户设置为操作者*/
        internal fun getOperator(operator: Any?, userInfo: EduBaseUserInfo, roomType: RoomType):
                EduBaseUserInfo {
            /**operator为空说明操作者是自己*/
            var operatorUser: EduBaseUserInfo? = null
            operator?.let {
                if (operator is EduUserRes) {
                    operatorUser = Convert.convertUserInfo(operator, roomType)
                } else if (operator is EduFromUserRes) {
                    operatorUser = Convert.convertUserInfo(operator, roomType)
                }
            }
            if (operatorUser == null) {
                operatorUser = userInfo
            }
            return operatorUser!!
        }

        /**处理同步过程中的有效数据，过滤出本地数据，并把本地数据从集合中remove掉
         * @param validDatas 同步过程中的有效数据
         * @return 同步过程中的有效数据中包含的本地数据*/
        internal fun processValidData(eduRoom: EduRoom, validDatas: Array<MutableList<out Any>>):
                Array<MutableList<Any>> {
            val validOnlineUserList = validDatas[0] as MutableList<EduUserInfo>
            val validModifiedUserList = validDatas[1] as MutableList<EduUserEvent>
            val validOfflineUserList = validDatas[2] as MutableList<EduUserEvent>
            val validAddedStreamList = validDatas[3] as MutableList<EduStreamEvent>
            val validModifiedStreamList = validDatas[4] as MutableList<EduStreamEvent>
            val validRemovedStreamList = validDatas[5] as MutableList<EduStreamEvent>

            val validModifiedLocalUsersBySyncing = mutableListOf<Any>()
            val validAddedLocalStreamsBySyncing = mutableListOf<Any>()
            val validModifiedLocalStreamsBySyncing = mutableListOf<Any>()
            val validRemovedLocalStreamsBySyncing = mutableListOf<Any>()

            if (validModifiedUserList.size > 0) {
                /**判断被修改的数据中是否有本地用户的数据*/
                val iterable = validModifiedUserList.iterator()
                while (iterable.hasNext()) {
                    val element = iterable.next()
                    if (element.modifiedUser == eduRoom.getLocalUser().userInfo) {
                        iterable.remove()
                        validModifiedLocalUsersBySyncing.add(element)
                    }
                }
            }
            if (validAddedStreamList.size > 0) {
                /**判断添加的流数据中是否有属于本地用户的流*/
                val iterable = validAddedStreamList.iterator()
                while (iterable.hasNext()) {
                    val element = iterable.next()
                    val streamInfo = element.modifiedStream
                    if (streamInfo.publisher == eduRoom.getLocalUser().userInfo) {
                        iterable.remove()
                        io.agora.rte.RteEngineImpl.updateLocalStream(streamInfo.hasAudio, streamInfo.hasVideo)
                        validAddedLocalStreamsBySyncing.add(element)
                    }
                }
            }
            if (validModifiedStreamList.size > 0) {
                /**判断被更改的流数据中是否有属于本地用户的流*/
                val iterable = validModifiedStreamList.iterator()
                while (iterable.hasNext()) {
                    val element = iterable.next()
                    if (element.modifiedStream.publisher == eduRoom.getLocalUser().userInfo) {
                        iterable.remove()
                        validModifiedLocalStreamsBySyncing.add(element)
                    }
                }
            }
            if (validRemovedStreamList.size > 0) {
                /**判断被移除的流数据中是否有属于本地用户的流*/
                val iterable = validRemovedStreamList.iterator()
                while (iterable.hasNext()) {
                    val element = iterable.next()
                    if (element.modifiedStream.publisher == eduRoom.getLocalUser().userInfo) {
                        validRemovedStreamList.remove(element)
                        validRemovedLocalStreamsBySyncing.add(element)
                    }
                }
            }
            return arrayOf(validModifiedLocalUsersBySyncing, validAddedLocalStreamsBySyncing,
                    validModifiedLocalStreamsBySyncing, validRemovedLocalStreamsBySyncing)
        }
    }
}