package io.agora.agoravoice.business;

import io.agora.agoravoice.business.implement.edu.EduBusinessProxy;
import io.agora.agoravoice.business.implement.rte.RteBusinessProxy;

public class BusinessProxyBuilder {
    private static final boolean USE_COMPATIBLE = true;

    public static BusinessProxy create(BusinessProxyContext context,
                                       BusinessProxyListener listener) {
        return USE_COMPATIBLE ? new EduBusinessProxy(context, listener)
                : new RteBusinessProxy(context, listener);
    }
}
