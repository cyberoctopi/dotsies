;;; -*- lexical-binding: t; -*-
(require 's)

(use-package elfeed
  :ensure t
  :commands
  (elfeed)
  :hook ((elfeed-search-mode . ar/elfeed-set-style))
  :bind (:map elfeed-search-mode-map
              ("R" . ar/elfeed-mark-all-as-read)
              ("d" . elfeed-search-untag-all-unread)
              ("v" . ar/elfeed-mark-visible-as-read)
              ("<tab>" . ar/elfeed-completing-filter)
              ("M-RET" . ar/elfeed-search-browse-background-url)
              ("B" . ar/elfeed-search-browse-background-url))
  :validate-custom
  (elfeed-search-title-max-width 120)
  (elfeed-search-print-entry-function #'ar/elfeed-search-print-entry)
  (elfeed-feeds '(
                  ("http://1w6.org/rss.xml" blog emacs draketo)
                  ("https://qiita.com/advent-calendar/2019/emacs/feed" blog emacs EmacsAdventCalendar2019)
                  ("https://genehack.blog/atom.xml" blog emacs genehack)
                  ("https://thomashartmann.dev/rss.xml" blog emacs ThomasHartmann)
                  ("https://invidio.us/feed/channel/UCWZ3HFiJkxG1K8C4HVnyBvQ" video invidious VicBerger)
                  ("https://www.ethanaa.com/rss.xml" blog emacs EthanAnderson)
                  ("https://menno.io/rss.xml" blog emacs Menno)
                  ("https://www.miskatonic.org/feed/all.xml" bloc emacs Miskatonic)
                  ("https://invidio.us/feed/channel/UCbpMy0Fg74eXXkvxJrtEn3w" video invidious BonApetit)
                  ("https://indieseek.xyz/feed" blog indie IndieSeek)
                  ("https://archive.casouri.cat/note/rss.xml" blog emacs casouri)
                  ("https://randomgeekery.org/index.xml" blog emacs RandomGeekery)
                  ("https://ricostacruz.com/til/rss.xml" blog dev)
                  ("https://invidio.us/feed/channel/UC5fdssPqmmGhkhsJi4VcckA" video invidious InnuendoStudios)
                  ("http://feeds.99percentinvisible.org/99percentinvisible" video design 99PercentInvisible)
                  ("https://betamax.video/feeds/videos.xml?sort=-trending" video peertube betamax)
                  ("https://tube.tchncs.de/feeds/videos.xml?sort=-trending" video peertube tchncs)
                  ("https://willschenk.com/feed.xml" blog emacs WillSchenk)
                  ("https://distinctly.pink/feed.xml" blog emacs DistinctlyPing)
                  ("https://confessionsfromaflightattendant.wordpress.com/feed" blog misc ConfessionsFromFlightAttendant)
                  ("http://200ok.ch/atom.xml" blog emacs 200ok)
                  ("https://noonker.github.io/index.xml" blog emacs noonker)
                  ("http://yqrashawn.com/feeds/lazyblorg-all.atom_1.0.links-only.xml" blog emacs yqrashawn)
                  ("https://www.reddit.com/r/listentothis/.rss" music reddit listentothis)
                  ("https://matthewbauer.us/blog/feed.xml" blog emacs MathewBauer)
                  ("http://akkartik.name/feeds.xml" blog dev)
                  ("https://tech.toryanderson.com/index.xml" blog emacs ToryAnderson)
                  ("https://eamonnsullivan.co.uk/feed.xml" blog emacs EamonnSullivan)
                  ("https://ungleich.ch/u/blog/feed.xml" blog NicoSchottelius)
                  ("http://amitp.blogspot.com/feeds/posts/default" blog emacs AmitPatel)
                  ("https://www.rousette.org.uk/index.xml" blog emacs BuyShesAGirl)
                  ("http://beard.institute/index.xml" blog emacs BeardInstitute)
                  ("https://alhassy.github.io/feed.xml" blog MusaAlhassy)
                  ("https://rebeja.eu/rss.xml" blog emacs PetruRebeja)
                  ("https://nalexn.github.io/feed.xml" blog swiftui swift AlexeyNaumov)
                  ("https://oracleyue.github.io/atom.xml" blog emacs oracleyue)
                  ("http://ben-evans.com/benedictevans?format=RSS" blog dev Ben-Evans)
                  ("https://haresfaiez.github.io/feed.xml" blog emacs  FaiezHares)
                  ("https://posts.michaelks.org/rss.xml" blog emacs MichaelElks)
                  ("https://azzamsa.com/feeds/all.atom.xml" blog emacs AzzamSyawqi)
                  ;; ("http://blog.abhixec.com/index.xml" blog emacs RandomMusings)
                  ("http://blog.davep.org/feed.xml" blog emacs davep)
                  ("http://blog.josephholsten.com/feed.xml" blog hammerspoon dev Libera-Ideoj)
                  ("http://blog.nawaz.org/feeds/all.atom.xml" blog emacs BeetleSpace)
                  ("http://buddhistinspiration.blogspot.com/feeds/posts/default" blog mindful BuddistInspiration)
                  ("http://cestlaz.github.io/rss.xml" blog emacs Zamansky)
                  ("http://cmsj.net/feed.xml" blog hammerspoon dev Chris-Jones)
                  ("http://dangrover.com/feed.xml" blog dangrover emacs )
                  ("https://sneak.berlin/feed.xml" blog emacs JeffreyPaul)
                  ("https://christiantietze.de/feed.atom" blog emacs ChristianTietze)
                  ("http://earlyretirementinuk.blogspot.com/feeds/posts/default" blog money EarlyRetirementUK)
                  ("http://emacslife.blogspot.com/feeds/posts/default" blog emacs emacslife)
                  ("https://jacmoes.wordpress.com/feed" blog emacs Jacmoe)
                  ("http://emacslisp.com/?feed=rss2" blog emacs WUDI)
                  ("http://emacsninja.com/atom.xml" blog emacs EmacsNinja)
                  ("http://emacsredux.com/atom.xml" blog emacs emacs-redux)
                  ("http://emacsworld.blogspot.com/feeds/posts/default?alt=rss" blog emacs EmacsWorld)
                  ("http://evgeni.io/categories/posts/index.xml" blog emacs Evgeni)
                  ("http://feeds.bbci.co.uk/news/uk/rss.xml?edition=uk" news BBCUK bbc)
                  ("http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk" news BBCWorld bbc)
                  ("http://feeds.feedblitz.com/atomicspin&x=1" blog dev emacs AtomicObject)
                  ("http://feeds.feedburner.com/AffordAnythingFeed" blog money AffordAnything)
                  ("http://feeds.feedburner.com/FinancialSamurai" blog money FinancialSamurai)
                  ("http://feeds.feedburner.com/JuanjoalvareznetPosts" blog emacs JuanjoAlvaro)
                  ("http://feeds.feedburner.com/NoufalIbrahim?format=xml" blog emacs NoufalIbrahim)
                  ("http://feeds.feedburner.com/NoufalIbrahim?format=xml" blog emacs NoufalIbrahim)
                  ("http://feeds.feedburner.com/japaneseruleof7" blog japan japanese-rule-of-7)
                  ("http://feeds2.feedburner.com/Monevatorcom" blog money Monevator)
                  ("http://fiukmoney.co.uk/feed" blog money FIUKMoney)
                  ("http://francismurillo.github.io/hacker/feed.xml" blog emacs francismurillo)
                  ("http://francismurillo.github.io/watcher/feed.xml" blog anime francismurillo)
                  ("http://irreal.org/blog/?feed=rss2" blog emacs Irreal)
                  ("http://johnbokma.com/index.rss" blog emacs JohnBokma)
                  ("http://justinhj.github.io/feed.xml" blog emacs FunctionalJustin)
                  ("http://kitchingroup.cheme.cmu.edu/blog/feed/atom" blog emacs JohnKitchin)
                  ("https://kundeveloper.com/index.xml" blog emacs KunDeveloper)
                  ("https://juliaferraioli.com/blog/index.xml" blog dev JuliaFerraioli)
                  ("http://liberate.life/index.php/feed/" blog money LiberateLife)
                  ("http://mbork.pl?action=rss" blog emacs MarcinBorkowski)
                  ("http://nullprogram.com/feed" blog emacs Chris-Wellons)
                  ("http://petercheng.net/index.xml" blog emacs PeterCheng)
                  ("http://planet.emacslife.com/atom.xml" blog emacs emacsen)
                  ("http://pragmaticemacs.com/feed" blog emacs PragmaticEmacs)
                  ("http://prodissues.com/feeds/all.atom.xml" blog emacs Prodissues)
                  ("http://quietlysaving.co.uk/feed" blog money QuietlySaving)
                  ("http://reddit.com/r/emacs/.rss" social reddit emacs)
                  ("http://rubyronin.com/wp-feed.php" blog japan travel the-ruby-ronin)
                  ("http://sachachua.com/blog/feed" blog emacs sachachua)
                  ("http://spensertruex.com/rss.xml" blog emacs SpenserTruex)
                  ("http://tangent.libsyn.com" blog money  ChristopherRyan)
                  ("http://tech.memoryimprintstudio.com/feed" blog emacs MemoryImprintStudio)
                  ("http://thefirestarter.co.uk/feed" blog money FireStarter)
                  ("http://trey-jackson.blogspot.com/feeds/posts/default" blog emacs TreyJackson)
                  ("http://tromey.com/blog/?feed=rss2" blog emacs TheCliffsOfInanity)
                  ("http://ukfipod.space/feed" blog money UKFIPod)
                  ("http://whattheemacsd.com/atom.xml" blog WhatTheEmacsD)
                  ("http://www.arcadianvisions.com/blog/rss.xml" blog emacs arcadianvisions)
                  ("http://www.badykov.com/feed.xml" blog emacs KrakenOfThought)
                  ("http://www.blogbyben.com/feeds/posts/default" blog emacs BlogByBen)
                  ("http://www.brool.com/index.xml" blog emacs Brool)
                  ("http://www.gonsie.com/blorg/feed.xml" blog emacs)
                  ;; ("http://www.holgerschurig.de/index.xml" blog emacs HolgerSchurig)
                  ("http://www.jesshamrick.com/atom.xml" blog emacs JessHamrick)
                  ("http://www.johnborwick.com/feed.xml"blog emacs JohnBorwick)
                  ("http://www.modernemacs.com/index.xml" blog emacs ModernEmacs)
                  ("http://www.moneyforthemoderngirl.org/feed" blog money MoneyForTheModernGirl)
                  ("http://www.msziyou.com/feed/" blog money ZiYou)
                  ("http://www.sastibe.de/index.xml" blog emacs SebastianSchweer)
                  ("http://www.thefrugalcottage.com/feed" blog money FrugalCottage)
                  ("http://www.thisiscolossal.com/feed" blog art Colossal)
                  ("http://zzamboni.org/index.xml" blog hammerspoon dev Diego-Martín-Zamboni)
                  ("https://3652daysblog.wordpress.com/feed" blog money 3652DaysBlog)
                  ("https://acidwords.com/feed.xml" blog emacs AcidWords)
                  ("https://affordanything.com/blog/feed" blog money AffordAnything)
                  ("https://ambrevar.xyz/rss.xml" blog emacs PierreNeidhardt)
                  ("https://apurplelife.com/feed" blog money PurpleLife)
                  ("https://aqeel.cc/feed.xml" blog emacs AqeelAkber)
                  ("https://arenzana.org/feed" blog emacs Isma)
                  ("https://babbagefiles.xyz/index.xml" blog emacs BabbageFiles)
                  ("https://barnacl.es/rss" startup Barnacles)
                  ("https://beepb00p.xyz/rss.xml" blog emacs JestemKróliczkiem)
                  ("https://bendersteed.gitlab.io/index.xml" blog emacs bendersteed)
                  ("https://blog.aaronbieber.com/feed.xml" blog emacs AaronBieber)
                  ("https://blog.binchen.org/rss.xml" blog emacs BinChen)
                  ("https://blog.burntsushi.net/index.xml" blog dev BurnedSushi)
                  ("https://blog.danielgempesaw.com/rss" blog emacs DanielGempesaw)
                  ("https://blog.davep.dev/rss.xml" blog emacs davepdev)
                  ("https://blog.einval.eu/feeds/all.atom.xml" blog emacs WojciechSiewierski)
                  ("https://blog.laurentcharignon.com/post/index.xml" blog emacs LaurentCharingnon)
                  ("https://blog.maya2250.com/feed" blog emacs Maya2250)
                  ("https://blog.mjh.io/rss.xml" blog emacs MattHamrick)
                  ("https://blog.moneysavingexpert.com/blog.rss" blog money MoneySavingExpert MartinLewis)
                  ("https://caolan.org/posts/rss.xml" blog emacs CaolanMcMahon)
                  ("https://changelog.com/feed" blog dev news JohnGoerzen)
                  ("https://changelog.complete.org/feed" blog emacs JohnGoerzen)
                  ("https://chaoticlab.io/feed.xml" blog emacs ChaoticLab)
                  ("https://chasinglogic.io/feed" blog emacs ChasingLogic)
                  ("https://codingquark.com/feed.xml" blog emacs Codingquark)
                  ;; ("https://coffeeandcode.neocities.org/atom.xml" blog emacs CoffeeAndCode)
                  ("https://colelyman.com/index.xml" blog emacs ColeLyman)
                  ("https://copyninja.info/feeds/all.atom.xml" blog dev copyninja)
                  ("https://curiousprogrammer.wordpress.com/feed" blog emacs ACuriousProgrammer)
                  ("https://d12frosted.io/atom.xml" blog emacs d12frosted)
                  ("https://jingsi.space/index.xml" blog emacs AkiraKomamura)
                  ("https://ddavis.io/index.xml" blog emacs )
                  ("https://deliberatelivinguk.wordpress.com/feed/" blog money DeliberateLivingUK)
                  ("https://dev.to/feed" blog dev DevTo)
                  ("https://developer.atlassian.com/blog/feed.xml" blog emacs attlasian)
                  ("https://dmolina.github.io/en/index.xml" blog emacs DanielMolina)
                  ("https://drfire.co.uk/feed" blog money DrFire)
                  ;; ("https://dschrempf.github.io/index.xml" blog emacs DominikSchrempf)
                  ("https://elephly.net/feed.xml" blog emacs Elephly)
                  ("https://emacs-doctor.com/feed.xml" blog emacs emacs-doctor)
                  ("https://emacs.cafe/feed.xml" blog emacs EmacsCafe)
                  ("https://emacsist.github.io/index.xml" blog emacs emacsist)
                  ("https://emacsnotes.wordpress.com/feed" blog emacs EmacsNotes)
                  ("https://engineering.collbox.co/index.xml" blog emacs Collbox)
                  ("https://engineering.collbox.co/index.xml" blog emacs Collbox)
                  ("https://ericasadun.com/feed" blog swift ios EricaSadun)
                  ("https://tanaschita.com/feed.rss" blog ios NataschaFadeeva)
                  ("https://erick.navarro.io/index.xml" dev emacs ErickNavarro)
                  ("https://etienne.depar.is/a-ecrit/feed/atom" blog emacs EtienneDeparis)
                  ("https://feeds.feedburner.com/Firehubeu" blog money FireHubEU)
                  ("https://feeds.feedburner.com/codinghorror" blog dev Coding-Horror)
                  ("https://feeds.feedburner.com/ryanmcgeary" blog emacs RyanMcGeary)
                  ("https://fireinlondon.wordpress.com/feed" blog money FireInLondon)
                  ("https://firevlondon.com/feed/" blog money FIREvsLondon)
                  ("https://frugalfoxes.home.blog/feed" blog money FrugalFoxes)
                  ("https://fuco1.github.io/rss.xml" blog emacs Fuco)
                  ("https://fumbling.it/posts/index.xml" blog emacs Fumbling)
                  ("https://ghuntley.com/rss" blog dev ghuntley)
                  ("https://github.crookster.org/feed.xml" blog dev emacs Crook)
                  ("https://hackeryarn.com/index.xml" blog emacs HackerYarn)
                  ("https://hacks.mozilla.org/feed" blog dev Mozilla)
                  ("https://harryrschwartz.com/atom.xml" bloc emacs HarryRSchwartz)
                  ("https://hasanyavuz.ozderya.net/?feed=rss2" blog emacs HasanYavuz)
                  ("https://hbfs.wordpress.com/feed" blog emacs StevenPigeon)
                  ;; ("https://howtosavecash.co.uk/feed" blog money HowToSaveCash)
                  ("https://humbledollar.com/blog/feed" blog money HumbleDollar)
                  ("https://iloveemacs.wordpress.com/feed" blog emacs ILoveEmacs)
                  ("https://increment.com/feed.xml" blog dev Increment)
                  ("https://indeedably.com/feed/" blog money InDeedABly)
                  ("https://jamesstuber.com/index.xml" blog lifestyle JamesStuber)
                  ("https://jarss.github.io/TAONAW/index.xml" blog emacs Jarss)
                  ("https://jmonlong.github.io/index.xml" blog emacs JeanMonlong)
                  ("https://joelmccracken.github.io/feed.xml" blog emacs JoelMcCracken)
                  ("https://jonathanabennett.github.io/rss.xml" blog emacs JonathanBennett)
                  ("https://jvns.ca/atom.xml" blog emacs JuliaEvans)
                  ("https://kdecherf.com/feeds/blog.atom.xml" blog dev kdecherf-blog)
                  ("https://kdecherf.com/feeds/le-kdecherf.atom.xml" blog dev kdecherf)
                  ("https://keyholesoftware.com/feed" blog emacs keyhole)
                  ("https://kisaragi-hiu.com/feed.xml" blog emacs KisaragiHiu)
                  ("https://krsoninikhil.github.io/atom.xml" blog emacs NikhilSoni)
                  ("https://lars.ingebrigtsen.no/feed" blog emacs LarsIngebrigtsen)
                  ("https://lchsk.com/posts.xml" blog emacs lchsk)
                  ("https://librelounge.org/rss-feed.rss" blog dev LibreLounge)
                  ("https://linuxhint.com/feed" blog emacs LinuxHint)
                  ("https://livingtechmagic.wordpress.com/comments/feed" blog emacs LivingTechMagic)
                  ("https://lobste.rs/rss" blog dev Lobsters)
                  ("https://manuel-uberti.github.io/feed.xml" blog emacs ManuelUberti)
                  ("https://manuel.is/index.xml" blog emacs ManuelGonzales)
                  ("https://martinralbrecht.wordpress.com/feed" blog emacs MartinAlbrecht)
                  ("https://martinralbrecht.wordpress.com/feed" blog emacs MartinralBrecht)
                  ("https://matt.hackinghistory.ca/feed/" blog emacs MattPrice)
                  ("https://mecid.github.io/feed.xml" blog ios swift Majid)
                  ("https://medium.com/feed/@tasshin" blog emacs meditation MichaelFogleman)
                  ("https://mhaffner.github.io/index.xml" blog emacs MatthewHaffner)
                  ("https://mickael.kerjean.me/feed.xml" blog emacs MickaelKerjean)
                  ("https://moneytothemasses.com/feed" money blog MoneyToTheMasses)
                  ("https://muratbuffalo.blogspot.com/feeds/posts/default?alt=rss" blog emacs MuratBuffale)
                  ("https://news.ycombinator.com/rss" hackernews tech)
                  ("https://nickdrozd.github.io/feed.xml" blog emacs NicholasDrozd)
                  ;; ("https://notanumber.io/feed.xml" blog emacs NotANumber)
                  ("https://ogbe.net/blog.xml" blog emacs dev DennisOgbe)
                  ("https://palikar.github.io/index.xml" blog emacs StanislavArnaudov)
                  ("https://pantarei.xyz/rss.xml" blog emacs PelleNilsson)
                  ("https://weblog.evenmere.org/atom.xml" blog emacs BrianSniffen)
                  ("https://patrickskiba.com/feed.xml" blog emacs PatrickSkiba)
                  ("https://people.gnome.org/~federico/blog/feeds/all.atom.xml" emacs FedericoMenaQuintero)
                  ("https://piware.de/post/index.xml" blog dev MartinPitt)
                  ("https://psachin.gitlab.io/index.xml" blog emacs SachinPatil)
                  ("https://punchagan.muse-amuse.in/index.xml" blog emacs Punchagan)
                  ("https://rodogi.github.io/post/index.xml" blog emacs RodrigoDorantes)
                  ("https://ryanfb.github.io/etc/feed.xml" blog dev RyanBaumann)
                  ("https://ryanholiday.net/feed/" blog meditation health RyanHoliday)
                  ("https://ryanholiday.net/feed/atom" blog emacs StringsNote)
                  ("https://sainathadapa.github.io/feed.xml" blog emacs SainathAdapa)
                  ("https://sam217pa.github.io/index.xml" blog emacs BacterialFinches)
                  ("https://sam217pa.github.io/index.xml" blog emacs BacterialFinches)
                  ("https://sciencebasedmedicine.org/feed" blog medicine health ScienceBasedMedicine)
                  ("https://scripter.co/posts/index.xml" blog emacs dev)
                  ("https://seeknuance.com/feed" blog emacs SeekNuance)
                  ("https://simplelivingsomerset.wordpress.com/feed/" blog money SimpleLivingSomerset)
                  ("https://solmaz.io/feed.xml" blog emacs OnurSolmaz)
                  ("https://stardiviner.github.io/Blog/index.xml" blog emacs Stardiviner)
                  ("https://stuff-things.net/atom.xml" blog emacs StuffThings)
                  ("https://swiftnews.curated.co/issues.rss" blog swift ios ShiftNewsCurated)
                  ("https://swiftweekly.github.io/feed.xml" blog swift ios SwiftWeekly)
                  ("https://systemreboot.net/feeds/blog.atom" blog emacs ArunIsaac)
                  ("https://tech.tonyballantyne.com/feed" blog emacs TonyBallantyne)
                  ;; ("https://thb.lt/atom.xml" blog emacs ThibaultPolge)
                  ("https://theescapeartist.me/feed/" blog money EscapeArtist)
                  ("https://thesavingninja.com/feed" blog money SavingNinja)
                  ("https://truongtx.me/atom.xml" blog emacs truongtx)
                  ("https://two-wrongs.com/atom" blog emacs TwoWrongs)
                  ("https://vadosware.io/index.xml" blog emacs Vadosware)
                  ("https://valignatev.com/index.xml" blog emacs ValentinIgnatev)
                  ("https://vicarie.in/archive.xml" blog emacs NarendraJoshi)
                  ("https://vxlabs.com/index.xml" blog emacs VXLabs)
                  ("https://webgefrickel.de/blog/feed" blog dev SteffenRademacker)
                  ("https://wincent.com/blog.rss" blog dev wincent)
                  ("https://write.as/dani/feed" blog emacs Daniel)
                  ("https://write.emacsen.net/feed" blog emacs WriteEmacsen)
                  ("https://writequit.org/posts.xml" blog emacs writequit)
                  ("https://www.baty.blog/feed.rss" blog emacs JackBatyBlog)
                  ("https://www.baty.net/index.xml" blog emacs JackBaty)
                  ("https://www.birkey.co/rss.xml" blog emacs KasimTuman)
                  ("https://www.bofh.org.uk/post/index.xml" blog emacs PiersCawley)
                  ("https://www.bogleheads.org/forum/feed?sid=a8ec975abd90862320b3ca6ac4da7f3c" money BoggleHeadsInvesting)
                  ("https://www.bogleheads.org/forum/feed?sid=f11d3ab0a9c9bb6211c46ac2e4f8ee23" money BoggleHeadsPersonalFinance)
                  ("https://www.bytedude.com/feed.xml" blog emacs MarcinS)
                  ("https://www.campfirefinance.com/feed" blog money CampFireFinance)
                  ("https://www.choosefi.com/category/podcast-episodes/feed" blog money ChoosefiPodcasts)
                  ("https://www.choosefi.com/feed/" blog money Choosefi)
                  ("https://grantisom.com/feed.xml" blog dev macos ios GrantIsom)
                  ("https://www.designboom.com/feed" blog art DesignBoom)
                  ("https://www.designernews.co/?format=atom" blog design DesignerNews)
                  ("https://www.drweil.com/blog/health-tips/feed" blog health healthTips DrWeil)
                  ("https://www.drweil.com/blog/spontaneous-happiness/feed" blog health happinessTips DrWeil)
                  ("https://www.foxymonkey.com/feed" blog money FoxMonkey)
                  ("https://www.fugue.co/blog/rss.xml" blog emacs Fugue)
                  ("https://www.getrichslowly.org/feed" blog money GetRichSlowly)
                  ("https://www.hasecke.eu/index.xml" blog emacs hasecke)
                  ;; ("https://www.ict4g.net/adolfo/site.atom" blog dev Adolfo)
                  ("https://www.johndcook.com/blog/feed" blog emacs JohnDCook)
                  ("https://www.kill-the-newsletter.com/feeds/9zjjxvudea119vhuwywk.xml" blog lifestyle RaisingSimple)
                  ("https://www.kill-the-newsletter.com/feeds/c5ujv8czvmqurjiompcy.xml" blog emacs GeekSocket)
                  ("https://www.kill-the-newsletter.com/feeds/igbrcacpr2hpwg1m7hcs.xml" newsletter ios iOSGoodies)
                  ("https://www.kill-the-newsletter.com/feeds/kaiqblkcbdo4uhnpbaln.xml" blog SkepticalRaptor)
                  ("https://www.kill-the-newsletter.com/feeds/qtfseubuhywlyqjtaeo9.xml" newsletter MorningBrew)
                  ("https://www.kill-the-newsletter.com/feeds/y0avwirj3b5jrgdygfyh.xml" newsletter SundayDispatches PaulJarvis)
                  ("https://www.lambdacat.com/rss" blog emacs LambdaCat)
                  ("https://www.madfientist.com/feed/" blog money MadFientist)
                  ("https://www.moneysavingexpert.com/news/feeds/news.rss" blog money MoneySavingExpert news)
                  ("https://www.mortens.dev/feeds/all.atom.xml" blog emacs)
                  ("https://www.ogre.com/blog/feed" blog dev Ogre)
                  ("https://www.producthunt.com/feed" blog products ProductHunt)
                  ("https://www.raptitude.com/feed" blog lifestyle Rapititude)
                  ("https://www.reddit.com/r/UKPersonalFinance/.rss" social reddit money UKPersonalFinanceSubreddit)
                  ("https://www.reddit.com/r/investing/.rss" social reddit money InvestingSubreddit)
                  ("https://www.romanzolotarev.com/rss.xml" blog bsd dev RomanZolotarev)
                  ("https://www.sandeepnambiar.com/feed.xml" blog emacs SandeepNambiar)
                  ("https://www.steventammen.com/index.xml" blog emacs StevenTammen)
                  ("https://www.swiftbysundell.com/posts?format=RSS" blog swift SwiftBySundell)
                  ("https://www.tomheon.com/index.xml" blog emacs Edmund)
                  ("https://www.wisdomandwonder.com/feed" blog emacs WisdomWonder)
                  ("https://www.with-emacs.com/rss.xml" blog emacs WithEmacs)
                  ("https://www.worthe-it.co.za/rss.xml" blog emacs JustinWernick)
                  ("https://yiufung.net/index.xml" blog emacs yiufung)
                  ("https://ylluminarious.github.io/feed.xml" blog emacs ylluminarious)
                  ("https://yoo2080.wordpress.com/feed" blog emacs YooBox)
                  ("https://spwhitton.name/blog/index.atom" blog emacs spwhitton)
                  ("https://youngfiguy.com/feed" blog money YoungFIGuy)
                  ("https://zacwood.me/atom.xml" blog emacs ZacWood)
                  ;; ("https://zcl.space/index.xml" blog emacs ZclSpace)
                  ("https://zerokspot.com/index.xml" blog emacs Zerokspot)
                  ("https://zhangda.wordpress.com/feed" blog emacs DaZhang)
                  ("https://zudepr.co.uk/feed" blog money Zude)
                  ("https://coredumped.dev/index.xml" blog emacs CoreDumped)
                  ("https://blog.vivekhaldar.com/rss" blog emacs VivekHaldar)
                  ("https://luna-studios.gitlab.io/luna-studios/index.xml" blog emacs LunaStudios)
                  ))
  :init
  (defun ar/elfeed-search-print-entry (entry)
    "My preferred format for displaying each elfeed search result ENTRY.
Based on `elfeed-search-print-entry--default'."
    (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
           ;; Decode HTML entities (ie. &amp;)
           ;; (title (ar/string-decode-html-entities (or (elfeed-meta entry :title) (elfeed-entry-title entry) "")))
           (title (or (elfeed-meta entry :title) (elfeed-entry-title entry) ""))
           (title-faces (elfeed-search--faces (elfeed-entry-tags entry)))
           (feed (elfeed-entry-feed entry))
           (feed-title
            (when feed
              (or (elfeed-meta feed :title) (elfeed-feed-title feed))))
           (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
           (tags-str (mapconcat
                      (lambda (s) (propertize s 'face 'elfeed-search-tag-face))
                      tags ","))
           (title-width (- (window-width) 10 elfeed-search-trailing-width))
           (title-column (elfeed-format-column
                          title (elfeed-clamp
                                 elfeed-search-title-min-width
                                 title-width
                                 elfeed-search-title-max-width)
                          :left)))
      (insert (propertize date 'face 'elfeed-search-date-face) " ")
      (insert (propertize title-column 'face title-faces 'kbd-help title) " ")
      (when feed-title
        (insert (propertize feed-title 'face 'elfeed-search-feed-face) " "))
      (when tags
        (insert "(" tags-str ")"))))

  (defun ar/elfeed-set-style ()
    ;; Separate elfeed lines for readability.
    (setq line-spacing 25))
  :config
  (defun ar/elfeed-mark-all-as-read ()
    "Mark all entries in search as read."
    (interactive)
    (mark-whole-buffer)
    (elfeed-search-untag-all-unread))

  (defun ar/elfeed-filter-results-count (search-filter)
    "Count results for SEARCH-FILTER."
    (let* ((filter (elfeed-search-parse-filter search-filter))
           (head (list nil))
           (tail head)
           (count 0))
      (let ((lexical-binding t)
            (func (byte-compile (elfeed-search-compile-filter filter))))
        (with-elfeed-db-visit (entry feed)
          (when (funcall func entry feed count)
            (setf (cdr tail) (list entry)
                  tail (cdr tail)
                  count (1+ count)))))
      count))

  (defun ar/elfeed-completing-filter ()
    "Completing filter."
    (interactive)
    (let ((categories (-filter
                       (lambda (item)
                         (> (ar/elfeed-filter-results-count (cdr item))
                            0))
                       '(("[All]" . "@6-months-ago +unread")
                         ("Art" . "@6-months-ago +unread +art")
                         ("BBC" . "@6-months-ago +unread +bbc")
                         ("Dev" . "@6-months-ago +unread +dev")
                         ("Emacs" . "@6-months-ago +unread +emacs")
                         ("Health" . "@6-months-ago +unread +health")
                         ("Hacker News" . "@6-months-ago +unread +hackernews")
                         ("iOS" . "@6-months-ago +unread +ios")
                         ("Money" . "@6-months-ago +unread +money")
                         ("Product Hunt" . "@6-months-ago +unread +ProductHunt")
                         ("Video" . "@6-months-ago +unread +video")
                         ("Travel" . "@6-months-ago +unread +travel")))))
      (if (> (length categories) 0)
          (progn
            (ar/elfeed-view-filtered (cdr (assoc (completing-read "Categories: " categories)
                                                 categories)))
            (goto-char (window-start)))
        (message "All caught up \\o/"))))

  (defun ar/elfeed-mark-visible-as-read ()
    (interactive)
    (when (yes-or-no-p "Mark page as read?")
      (set-mark (window-start))
      (goto-char (window-end-visible))
      (activate-mark)
      (elfeed-search-untag-all-unread)
      (elfeed-search-update--force)
      (deactivate-mark)
      (goto-char (window-start))))

  ;; Going back to defaults for a little while.
  ;; (use-package elfeed-goodies :ensure t
  ;;   :after elfeed
  ;;   :config
  ;;   (ar/vsetq elfeed-goodies/entry-pane-position 'bottom)
  ;;   (ar/vsetq elfeed-goodies/feed-source-column-width 30)
  ;;   (ar/vsetq elfeed-goodies/tag-column-width 35)
  ;;   (elfeed-goodies/setup))

  (defun ar/elfeed-search-browse-background-url ()
    "Open current `elfeed' entry (or region entries) in browser without losing focus."
    (interactive)
    (let ((entries (elfeed-search-selected)))
      (mapc (lambda (entry)
              (assert (memq system-type '(darwin)) t "open command is macOS only")
              (start-process (concat "open " (elfeed-entry-link entry))
                             nil "open" "--background" (elfeed-entry-link entry))
              (elfeed-untag entry 'unread)
              (elfeed-search-update-entry entry))
            entries)
      (unless (or elfeed-search-remain-on-entry (use-region-p))
        (forward-line))))

  (defun ar/elfeed-open-youtube-video ()
    (interactive)
    (let ((link (elfeed-entry-link elfeed-show-entry)))
      (when link
        (ar/open-youtube-url link))))

  (defun ar/elfeed-view-filtered (filter)
    "Filter the elfeed-search buffer to show feeds tagged with FILTER."
    (interactive)
    (elfeed)
    (unwind-protect
        (let ((elfeed-search-filter-active :live))
          (setq elfeed-search-filter filter))
      (elfeed-search-update :force))))

(use-package org-web-tools
  :ensure t
  :config
  (use-package esxml
    :ensure t)

  (require 'cl-macs)

  ;; From https://github.com/alphapapa/unpackaged.el#feed-for-url
  (cl-defun ar/feed-for-url-in-clipboard (url &key (prefer 'atom) (all nil))
    "Return feed URL for web page at URL.
Interactively, insert the URL at point.  PREFER may be
`atom' (the default) or `rss'.  When ALL is non-nil, return all
feed URLs of all types; otherwise, return only one feed URL,
preferring the preferred type."
    (interactive (list (org-web-tools--get-first-url)))
    (require 'esxml-query)
    (require 'org-web-tools)
    (cl-flet ((feed-p (type)
                      ;; Return t if TYPE appears to be an RSS/ATOM feed
                      (string-match-p (rx "application/" (or "rss" "atom") "+xml")
                                      type)))
      (let* ((preferred-type (format "application/%s+xml" (symbol-name prefer)))
             (html (org-web-tools--get-url url))
             (dom (with-temp-buffer
                    (insert html)
                    (libxml-parse-html-region (point-min) (point-max))))
             (potential-feeds (esxml-query-all "link[rel=alternate]" dom))
             (return (if all
                         ;; Return all URLs
                         (cl-loop for (tag attrs) in potential-feeds
                                  when (feed-p (alist-get 'type attrs))
                                  collect (url-expand-file-name (alist-get 'href attrs) url))
                       (or
                        ;; Return the first URL of preferred type
                        (cl-loop for (tag attrs) in potential-feeds
                                 when (equal preferred-type (alist-get 'type attrs))
                                 return (url-expand-file-name (alist-get 'href attrs) url))
                        ;; Return the first URL of non-preferred type
                        (cl-loop for (tag attrs) in potential-feeds
                                 when (feed-p (alist-get 'type attrs))
                                 return (url-expand-file-name (alist-get 'href attrs) url))))))
        (assert return nil "No feed found")
        (if (called-interactively-p)
            (insert (if (listp return)
                        (s-join " " return)
                      return))
          return)))))

(defun ar/open-youtube-url (url)
  "Download and open youtube URL."
  ;; Check for URLs like:
  ;; https://www.youtube.com/watch?v=rzQEIRRJ2T0
  ;; https://youtu.be/rzQEIRRJ2T0
  (setq url (s-trim url))
  (assert (or (string-match-p "^http[s]?://\\(www\\.\\)?\\(\\(youtube.com\\)\\|\\(m.youtube.com\\)\\|\\(youtu.be\\)\\|\\(soundcloud.com\\)\\|\\(redditmedia.com\\)\\)" url)
              (string-match-p "^http[s]?://.*bandcamp.com" url))
          nil "Not a downloadable URL: %s" url)
  (message "Downloading: %s" url)
  (async-start
   `(lambda ()
      (shell-command-to-string
       (format "youtube-dl --newline -o \"~/Downloads/%%(title)s.%%(ext)s\" %s" ,url)))
   `(lambda (output)
      (if (string-match-p "ERROR:" output)
          (message "%s" output)
        (message "Downloaded: %s" ,url)))))

(defun ar/open-youtube-clipboard-url ()
  "Open youtube video from url in clipboard."
  (interactive)
  (ar/open-youtube-url (current-kill 0)))

(defun ar/open-youtube-clipboard-from-page-url ()
  "Open youtube video from page url in clipboard."
  (interactive)
  (require 'ar-url)
  (require 'dash)
  (let ((youtube-urls (-union
                       ;; Look for iframe.
                       (-filter (lambda (iframe-url)
                                  (string-match "\\(youtube.com\\)\\|\\(youtu.be\\)\\|\\(redditmedia.com\\)" iframe-url))
                                (ar/url-fetch-iframe-srcs (current-kill 0)))
                       ;; Look for links.
                       (-map (lambda (anchor)
                               (let-alist anchor
                                 .url))
                             (-filter (lambda (anchor)
                                        (let-alist anchor
                                          (string-match "youtube" .url)))
                                      (ar/url-fetch-anchor-elements (current-kill 0)))))))
    (assert (> (length youtube-urls) 0) nil "No youtube links found")
    (if (= (length youtube-urls) 1)
        (ar/open-youtube-url (nth 0 youtube-urls))
      (ar/open-youtube-url (completing-read "choose:" youtube-urls)))))

(use-package ytel
  :ensure t
  :bind (:map ytel-mode-map
              ("RET" . ar/ytel-watch)
              ("M-RET" . ar/ytel-download-video-at-point))
  :hook ((ytel-mode . (lambda ()
                        (toggle-truncate-lines nil))))
  :config
  (defun ar/ytel-watch ()
    "Stream video at point in mpv."
    (interactive)
    (let* ((video (ytel-get-current-video))
     	   (id    (ytel-video-id video)))
      (start-process "ytel mpv" nil
		     "mpv"
		     (concat "https://www.youtube.com/watch?v=" id))
      "--ytdl-format=bestvideo[height<=?720]+bestaudio/best")
    (message "Starting streaming..."))


  (defun ar/ytel-download-video-at-point ()
    "Download video at point."
    (interactive)
    (let* ((video (ytel-get-current-video))
     	   (id    (ytel-video-id video)))
      (ar/open-youtube-url (concat "https://www.youtube.com/watch?v=" id)))
    (message "Downloading...")))
