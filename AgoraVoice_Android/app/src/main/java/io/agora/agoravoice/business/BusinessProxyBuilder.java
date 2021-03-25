package io.agora.agoravoice.business;

import io.agora.agoravoice.business.implement.rte.RteBusinessProxy;

public class BusinessProxyBuilder {
    public static BusinessProxy create(BusinessProxyContext context,
                                       BusinessProxyListener listener) {
        return new RteBusinessProxy(context, listener);
    }
}
