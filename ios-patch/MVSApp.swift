import WebKit
let MVS_MAIN_JS = #"(function(){try{var d=document.createElement('div');d.setAttribute('aria-hidden','true');d.style.cssText='position:fixed;left:0;bottom:0;width:100%;height:2px;overflow:hidden;white-space:nowrap;font:1px/1px sans-serif;color:#fff;pointer-events:none;z-index:2147483647';d.textContent=new Array(60).join('Munfordville Sports ');(document.body||document.documentElement).appendChild(d);setTimeout(function(){d.remove()},6000);var m=document.querySelector('meta[name=viewport]');if(m){if(m.content.indexOf('viewport-fit')<0){m.content=m.content+',viewport-fit=cover'}}else{m=document.createElement('meta');m.name='viewport';m.content='width=device-width,initial-scale=1,viewport-fit=cover';document.head.appendChild(m)}var ins=function(){var p=document.createElement('div');p.style.cssText='position:fixed;top:0;left:0;padding-top:env(safe-area-inset-top);padding-bottom:env(safe-area-inset-bottom);visibility:hidden';document.documentElement.appendChild(p);var cs=getComputedStyle(p);var r={t:parseFloat(cs.paddingTop)||0,b:parseFloat(cs.paddingBottom)||0};p.remove();return r};window.addEventListener('message',function(e){if(e.data&&e.data.mvsNeedInsets){try{e.source.postMessage({mvsInsets:ins()},'*')}catch(x){}}})}catch(err){}})();"#
let MVS_FRAME_JS = #"(function(){try{if(location.host.indexOf('filesusr')<0)return;var apply=function(i){var s=document.getElementById('mvs-ins')||document.createElement('style');s.id='mvs-ins';s.textContent='#hdr{padding-top:'+i.t+'px!important;height:calc(58px + '+i.t+'px)!important;box-sizing:border-box}#main{top:calc(58px + '+i.t+'px)!important;bottom:calc(66px + '+i.b+'px)!important}#tabs{height:calc(66px + '+i.b+'px)!important;padding-bottom:'+i.b+'px!important;box-sizing:border-box}';(document.head||document.documentElement).appendChild(s)};window.addEventListener('message',function(e){if(e.data&&e.data.mvsInsets){apply(e.data.mvsInsets)}});var n=0;var ask=function(){try{parent.postMessage({mvsNeedInsets:1},'*')}catch(x){}n++;if(n<6){setTimeout(ask,700)}};ask()}catch(err){}})();"#
class MVSViewController: CAPBridgeViewController {
    // Plain web view setup: same settings Capacitor uses, minus its cookie-sync observer.
    override func webViewConfiguration(for instanceConfiguration: InstanceConfiguration) -> WKWebViewConfiguration {
        let c = WKWebViewConfiguration()
        c.allowsInlineMediaPlayback = true
        c.suppressesIncrementalRendering = false
        c.allowsAirPlayForMediaPlayback = true
        c.mediaTypesRequiringUserActionForPlayback = []
        c.limitsNavigationsToAppBoundDomains = instanceConfiguration.limitsNavigationsToAppBoundDomains
        if #available(iOS 15.4, *) { c.preferences.isElementFullscreenEnabled = true }
        c.defaultWebpagePreferences.preferredContentMode = .mobile
        return c
    }
    // Remove Capacitor's injected bridge/cordova scripts (they freeze the Wix page) and add our safe-area fixes.
    override func capacitorDidLoad() {
        super.capacitorDidLoad()
        guard let ucc = webView?.configuration.userContentController else { return }
        ucc.removeAllUserScripts()
        ucc.addUserScript(WKUserScript(source: MVS_MAIN_JS, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        ucc.addUserScript(WKUserScript(source: MVS_FRAME_JS, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
    }
}
