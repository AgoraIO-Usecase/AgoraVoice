package io.agora.agoravoice.business.implement.edu;

import androidx.annotation.NonNull;

import io.agora.agoravoice.business.BusinessProxy;
import io.agora.agoravoice.business.BusinessProxyContext;
import io.agora.agoravoice.business.BusinessProxyListener;
import io.agora.agoravoice.business.definition.interfaces.CoreService;

public class EduBusinessProxy extends BusinessProxy {
    public EduBusinessProxy(@NonNull BusinessProxyContext context, @NonNull BusinessProxyListener listener) {
        super(context, listener);
    }

    @Override
    protected @NonNull CoreService getCoreService(BusinessProxyContext context) {
        return new EduCoreService(
                context.getContext(),
                context.getAppId(),
                context.getCertificate(),
                context.getCustomerId(),
                context.getLogFile(),
                context.getLogLevel());
    }
}
