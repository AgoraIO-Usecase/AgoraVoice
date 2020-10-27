package io.agora.agoravoice.business.definition.struct;

public class AppVersionInfo {
    public String appCode;
    public int osType;
    public int terminalType;
    public String appVersion;
    public String latestVersion;
    public String appPackage;
    public String upgradeDescription;
    public int forcedUpgrade;
    public String upgradeUrl;
    public int reviewing;
    public int remindTimes;
    public AppId config;

    public static class AppId {
        public String appId;
    }
}
