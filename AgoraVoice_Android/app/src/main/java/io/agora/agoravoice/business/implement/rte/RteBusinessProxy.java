package io.agora.agoravoice.business.implement.rte;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.BusinessProxyContext;
import io.agora.agoravoice.business.BusinessProxyListener;
import io.agora.agoravoice.business.definition.interfaces.CoreService;

public class RteBusinessProxy extends BusinessProxy {
    public RteBusinessProxy(BusinessProxyContext context, @NonNull BusinessProxyListener listener) {
        super(context, listener);
    }

    @Override
    protected CoreService getCoreService(BusinessProxyContext context) {
        return new RteCoreService(
                context.getContext(),
                context.getAppId(),
                context.getCertificate(),
                context.getCustomerId());
    }
}
