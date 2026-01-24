import Foundation
#if canImport(UIKit)
import UIKit
#endif

final class InstalledAppsProvider {
    
    // MARK: - Common app URL schemes to detect installed apps (works without jailbreak/developer options)
    private static let commonApps: [(bundleId: String, name: String, urlScheme: String)] = [
        // Games
        ("com.supercell.clashofclans", "Clash of Clans", "clashofclans://"),
        ("com.supercell.clashroyale", "Clash Royale", "clashroyale://"),
        ("com.supercell.brawlstars", "Brawl Stars", "brawlstars://"),
        ("com.king.candycrushsaga", "Candy Crush Saga", "candycrush://"),
        ("com.rovio.angrybirds", "Angry Birds", "angrybirds://"),
        ("com.innersloth.amongus", "Among Us", "amongus://"),
        ("com.roblox.robloxmobile", "Roblox", "robloxmobile://"),
        ("com.mojang.minecraftpe", "Minecraft", "minecraft://"),
        ("com.miHoYo.GenshinImpact", "Genshin Impact", "genshinimpact://"),
        ("com.pubg.krmobile", "PUBG Mobile", "pubgmobile://"),
        ("com.tencent.ig", "PUBG Mobile", "tencent-ig://"),
        ("com.tencent.tmgp.pubgmhd", "PUBG Mobile", "pubgmobilehd://"),
        ("com.activision.callofduty.shooter", "Call of Duty Mobile", "callofdutymobile://"),
        ("com.garena.game.codm", "COD Mobile Garena", "codmgarena://"),
        ("com.ea.ios.apexlegendsmobilefps", "Apex Legends Mobile", "apexmobile://"),
        ("com.epicgames.fortnite", "Fortnite", "fortnite://"),
        ("games.lol.wildrift", "League of Legends Wild Rift", "wildrift://"),
        ("com.dts.freefireth", "Free Fire", "freefire://"),
        ("com.garena.game.fctw", "Free Fire TW", "freefiremax://"),
        ("com.gameloft.asphalt9", "Asphalt 9", "asphalt9://"),
        ("com.ea.game.fifa20companion", "FIFA Companion", "eafifacompanion://"),
        ("com.ea.ios.fifaultimate", "FIFA Mobile", "fifamobile://"),
        ("com.netease.pomelo.proxy", "LifeAfter", "lifeafter://"),
        ("com.tencent.lolm", "League of Legends Wild Rift", "lolm://"),
        ("com.lilithgame.roc.ios", "Rise of Kingdoms", "riseofkingdoms://"),
        ("com.playdemic.golf.clash", "Golf Clash", "golfclash://"),
        
        // Streaming & Entertainment
        ("com.netflix.Netflix", "Netflix", "nflx://"),
        ("com.google.ios.youtube", "YouTube", "youtube://"),
        ("com.spotify.client", "Spotify", "spotify://"),
        ("com.disney.disneyplus", "Disney+", "disneyplus://"),
        ("com.hbo.hbonow", "HBO Max", "hbomax://"),
        ("com.amazon.aiv.AIVApp", "Prime Video", "aiv://"),
        ("com.apple.tv", "Apple TV", "videos://"),
        ("tv.twitch", "Twitch", "twitch://"),
        ("com.zhiliaoapp.musically", "TikTok", "snssdk1128://"),
        
        // Social
        ("com.facebook.Facebook", "Facebook", "fb://"),
        ("com.burbn.instagram", "Instagram", "instagram://"),
        ("com.atebits.Tweetie2", "Twitter", "twitter://"),
        ("com.snapchat.snapchat", "Snapchat", "snapchat://"),
        ("net.whatsapp.WhatsApp", "WhatsApp", "whatsapp://"),
        ("com.facebook.Messenger", "Messenger", "fb-messenger://"),
        ("org.telegram.Telegram-iOS", "Telegram", "telegram://"),
        ("com.discord.ios", "Discord", "discord://"),
        ("com.reddit.Reddit", "Reddit", "reddit://"),
        ("ph.telegra.Telegraph", "Telegram X", "tgx://"),
        ("com.linkedin.LinkedIn", "LinkedIn", "linkedin://"),
        ("com.pinterest", "Pinterest", "pinterest://"),
        
        // Productivity & Utilities
        ("com.google.Gmail", "Gmail", "googlegmail://"),
        ("com.google.Maps", "Google Maps", "comgooglemaps://"),
        ("com.google.chrome.ios", "Chrome", "googlechrome://"),
        ("com.google.Drive", "Google Drive", "googledrive://"),
        ("com.google.photos", "Google Photos", "googlephotos://"),
        ("com.microsoft.Office.Outlook", "Outlook", "ms-outlook://"),
        ("com.microsoft.Office.Word", "Word", "ms-word://"),
        ("com.microsoft.Office.Excel", "Excel", "ms-excel://"),
        ("com.dropbox.Dropbox", "Dropbox", "dbapi-1://"),
        ("com.apple.Keynote", "Keynote", "x-keynote://"),
        ("com.apple.Pages", "Pages", "x-pages://"),
        ("com.apple.Numbers", "Numbers", "x-numbers://"),
        
        // Shopping
        ("com.amazon.Amazon", "Amazon", "amzn://"),
        ("com.ebay.iphone", "eBay", "ebay://"),
        ("com.walmart.electronics", "Walmart", "walmart://"),
        ("com.target.TargetApp", "Target", "target://"),
        
        // Finance
        ("com.paypal.PPClient", "PayPal", "paypal://"),
        ("com.squareup.cashme", "Cash App", "cashme://"),
        ("com.venmo.Venmo", "Venmo", "venmo://"),
        ("com.coinbase.Coinbase", "Coinbase", "coinbase://"),
        
        // Food
        ("com.ubercab.UberEats", "Uber Eats", "ubereats://"),
        ("com.grubhub.iphoneclient", "Grubhub", "grubhub://"),
        ("com.doordash.iphone.consumer", "DoorDash", "doordash://"),
        ("com.starbucks.mystarbucks", "Starbucks", "sbucks://"),
        ("com.mcdonalds.mobileapp", "McDonald's", "mcdonalds://"),
        
        // Travel & Transport
        ("com.ubercab.UberClient", "Uber", "uber://"),
        ("com.getlyft.ios", "Lyft", "lyft://"),
        ("com.airbnb.app", "Airbnb", "airbnb://"),
        ("com.booking.BookingApp", "Booking.com", "booking://"),
        ("com.tripadvisor.LocalPicks", "Tripadvisor", "tripadvisor://"),
    ]
    
    // MARK: - Fetch installed apps
    
    /// Returns an array of InstalledApp. Tries private API first, then falls back to URL scheme detection.
    /// Works on non-jailbroken devices without developer options enabled.
    static func fetchInstalledApps() -> [InstalledApp] {
        // First try private API (works on jailbroken devices or with entitlements)
        let privateAPIResults = fetchUsingPrivateAPI()
        if !privateAPIResults.isEmpty {
            return privateAPIResults
        }
        
        // Fallback: detect apps using URL schemes (works on all devices, no special permissions needed)
        return fetchUsingURLSchemes()
    }
    
    /// Detect installed apps by checking if their URL schemes can be opened
    /// This works on all iOS devices without jailbreak or developer options
    private static func fetchUsingURLSchemes() -> [InstalledApp] {
        var results: [InstalledApp] = []
        
        #if canImport(UIKit)
        for app in commonApps {
            if let url = URL(string: app.urlScheme) {
                // canOpenURL works without any special permissions on iOS
                // Note: Apps need to declare queried schemes in Info.plist for iOS 9+
                // But checking common schemes often works
                if UIApplication.shared.canOpenURL(url) {
                    // Avoid duplicates (some apps have multiple URL schemes)
                    if !results.contains(where: { $0.bundleId == app.bundleId }) {
                        results.append(InstalledApp(bundleId: app.bundleId, name: app.name))
                    }
                }
            }
        }
        #endif
        
        // Sort by name
        results.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return results
    }
    
    /// Try to use private API LSApplicationWorkspace (may not work without jailbreak)
    private static func fetchUsingPrivateAPI() -> [InstalledApp] {
        var results: [InstalledApp] = []

        guard let workspaceClass = NSClassFromString("LSApplicationWorkspace") else {
            return []
        }

        let selDefault = NSSelectorFromString("defaultWorkspace")
        guard let workspaceUnk = (workspaceClass as AnyObject).perform(selDefault)?.takeUnretainedValue() else {
            return []
        }

        let selAll = NSSelectorFromString("allApplications")
        guard let appsObj = (workspaceUnk as AnyObject).perform(selAll)?.takeUnretainedValue() as? [AnyObject] else {
            return []
        }

        for appProxy in appsObj {
            let bundleId = (appProxy as AnyObject).perform(NSSelectorFromString("applicationIdentifier"))?.takeUnretainedValue() as? String
                ?? (appProxy as AnyObject).perform(NSSelectorFromString("bundleIdentifier"))?.takeUnretainedValue() as? String
                ?? ""

            let name = (appProxy as AnyObject).perform(NSSelectorFromString("localizedName"))?.takeUnretainedValue() as? String
                ?? (appProxy as AnyObject).perform(NSSelectorFromString("localizedDisplayName"))?.takeUnretainedValue() as? String
                ?? bundleId

            if !bundleId.isEmpty {
                results.append(InstalledApp(bundleId: bundleId, name: name))
            }
        }

        // Sort by name
        results.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return results
    }
    
    // MARK: - Storage paths that work without jailbreak
    
    /// Get the path where preferences are saved (works on non-jailbroken devices)
    static func getPreferencesPath() -> URL {
        // Try App Group first (for sharing with extensions/widgets)
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.satella.prefs") {
            return groupURL.appendingPathComponent("com.satella.selected.plist")
        }
        
        // Fallback to app's Documents directory (always accessible without jailbreak)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("com.satella.selected.plist")
    }
    
    /// Persist selected bundle identifier to a plist file
    /// Uses app sandbox (Documents) on non-jailbroken devices, system prefs on jailbroken
    static func saveSelected(bundleId: String) throws {
        let dict: [String: Any] = ["selectedBundleId": bundleId]
        let data = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
        
        // Try jailbroken path first
        let jailbrokenPath = "/var/mobile/Library/Preferences/com.satella.selected.plist"
        if FileManager.default.isWritableFile(atPath: "/var/mobile/Library/Preferences/") {
            try data.write(to: URL(fileURLWithPath: jailbrokenPath))
            return
        }
        
        // Fallback to sandboxed storage (works on all devices)
        let sandboxedPath = getPreferencesPath()
        try data.write(to: sandboxedPath)
    }
    
    /// Load previously selected bundle ID
    static func loadSelected() -> String? {
        // Try jailbroken path first
        let jailbrokenPath = "/var/mobile/Library/Preferences/com.satella.selected.plist"
        if FileManager.default.fileExists(atPath: jailbrokenPath),
           let dict = NSDictionary(contentsOfFile: jailbrokenPath) as? [String: Any] {
            return dict["selectedBundleId"] as? String
        }
        
        // Try sandboxed path
        let sandboxedPath = getPreferencesPath()
        if FileManager.default.fileExists(atPath: sandboxedPath.path),
           let dict = NSDictionary(contentsOf: sandboxedPath) as? [String: Any] {
            return dict["selectedBundleId"] as? String
        }
        
        return nil
    }
}
