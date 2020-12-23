package io.agora.education.api.stream.data

open class StreamInitOptions(
        var streamUuid: String,
        var streamName: String? = null
)

class LocalStreamInitOptions(
        streamUuid: String,
        var enableCamera: Boolean = true,
        var enableMicrophone: Boolean = true
) : StreamInitOptions(streamUuid)

class ScreenStreamInitOptions(
        streamUuid: String,
        streamName: String
) : StreamInitOptions(streamUuid, streamName)
