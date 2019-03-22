(require 'ar-vsetq)

(require 'ar-string)

(defun ar/open-youtube-url (url)
  "Download and open youtube URL."
  ;; Check for URLs like:
  ;; https://www.youtube.com/watch?v=rzQEIRRJ2T0
  ;; https://youtu.be/rzQEIRRJ2T0
  (assert (string-match-p "^http[s]?://\\(www\\.\\)?\\(\\(youtube.com\\)\\|\\(youtu.be\\)\\|\\(soundcloud.com\\)\\)" url)
          nil "Not a downloadable URL: %s" url)
  (message "Downloading: %s" url)
  (async-start
   `(lambda ()
      (shell-command-to-string
       (format "youtube-dl --newline --exec \"open -a VLC {}\" -o \"~/Downloads/%%(title)s.%%(ext)s\" %s" ,url)))
   `(lambda (output)
      (if (string-match-p "ERROR:" output)
          (message "%s" output)
        (message "Opened: %s" ,url)))))

(defun ar/open-youtube-clipboard-url ()
  "Download youtube video from url in clipboard."
  (interactive)
  (ar/open-youtube-url (current-kill 0)))

(use-package elfeed :ensure t
  :commands elfeed
  :hook ((elfeed-search-mode . ar/elfeed-set-style))
  :bind (:map elfeed-search-mode-map
              ("R" . ar/elfeed-mark-all-as-read)
              ("d" . elfeed-search-untag-all-unread)
              ("v" . ar/elfeed-mark-visible-as-read)
              ("<tab>" . ar/elfeed-completing-filter))
  :init
  (defun ar/elfeed-set-style ()
    ;; Separate elfeed lines for readability.
    (ar/vsetq line-spacing 25))

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
                         ("Travel" . "@6-months-ago +unread +travel")))))
      (if (> (length categories) 0)
          (progn
            (ar/elfeed-view-filtered (cdr (assoc (completing-read "Categories: " categories)
                                                 categories)))
            (goto-char (window-start)))
        (message "All caught up \\o/"))))

  :config
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

  (defun ar/elfeed-open-youtube-video ()
    (interactive)
    (let ((link (elfeed-entry-link elfeed-show-entry)))
      (when link
        (ar/open-youtube-url link))))

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

  (ar/vsetq elfeed-search-print-entry-function #'ar/elfeed-search-print-entry)

  (ar/vsetq elfeed-feeds
            '(
              ("http://1w6.org/rss.xml" blog emacs draketo)
              ("http://200ok.ch/atom.xml" blog emacs 200ok)
              ("https://solmaz.io/atom.xml" blog emacs OnurSolmaz)
              ("http://akkartik.name/feeds.xml" blog dev)
              ("http://amitp.blogspot.com/feeds/posts/default" blog emacs AmitPatel)
              ("http://ben-evans.com/benedictevans?format=RSS" blog dev Ben-Evans)
              ("http://blog.abhixec.com/index.xml" blog emacs RandomMusings)
              ("http://blog.davep.org/feed.xml" blog emacs davep)
              ("http://blog.josephholsten.com/feed.xml" blog hammerspoon dev Libera-Ideoj)
              ("http://blog.nawaz.org/feeds/all.atom.xml" blog dev )
              ("http://buddhistinspiration.blogspot.com/feeds/posts/default" blog mindful BuddistInspiration)
              ("http://cestlaz.github.io/rss.xml" blog emacs Zamansky)
              ("http://cmsj.net/feed.xml" blog hammerspoon dev Chris-Jones)
              ("http://dangrover.com/feed.xml" blog dangrover emacs )
              ("http://dividendlife.com/feed" blog money DividendLife)
              ("http://earlyretirementinuk.blogspot.com/feeds/posts/default" blog money EarlyRetirementUK)
              ("http://emacslife.blogspot.com/feeds/posts/default" blog emacs emacslife)
              ("http://feeds.feedburner.com/NoufalIbrahim?format=xml" blog emacs NoufalIbrahim)
              ("http://emacsredux.com/atom.xml" blog emacs emacs-redux)
              ("http://emacsworld.blogspot.com/feeds/posts/default?alt=rss" blog emacs EmacsWorld)
              ("http://evgeni.io/categories/posts/index.xml" blog emacs Evgeni)
              ("http://feeds.bbci.co.uk/news/uk/rss.xml?edition=uk" news BBCUK bbc)
              ("http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk" news BBCWorld bbc)
              ("http://feeds.feedblitz.com/atomicspin&x=1" blog dev emacs AtomicObject)
              ("http://feeds.feedburner.com/AffordAnythingFeed" blog money AffordAnything)
              ("http://feeds.feedburner.com/FinancialSamurai" blog money FinancialSamurai)
              ("http://feeds.feedburner.com/japaneseruleof7" blog japan japanese-rule-of-7)
              ("http://feeds2.feedburner.com/Monevatorcom" blog money Monevator)
              ("http://fiukmoney.co.uk/feed" blog money FIUKMoney)
              ("http://francismurillo.github.io/hacker/feed.xml" blog emacs francismurillo)
              ("http://francismurillo.github.io/watcher/feed.xml" blog anime francismurillo)
              ("http://irreal.org/blog/?feed=rss2" blog emacs Irreal)
              ("http://kitchingroup.cheme.cmu.edu/blog/feed/atom" blog emacs JohnKitchin)
              ("http://kundeveloper.com/feed" blog emacs KunDeveloper)
              ("http://mbork.pl?action=rss" blog emacs MarcinBorkowski)
              ("http://nullprogram.com/feed" blog emacs Chris-Wellons)
              ("http://petercheng.net/index.xml" blog emacs PeterCheng)
              ("http://planet.emacsen.org/atom.xml" blog emacs emacsen)
              ("http://pragmaticemacs.com/feed" blog emacs PragmaticEmacs)
              ("http://prodissues.com/feeds/all.atom.xml" blog emacs Prodissues)
              ("http://quietlysaving.co.uk/feed" blog money QuietlySaving)
              ("http://reddit.com/r/emacs/.rss" social reddit emacs)
              ("http://rubyronin.com/wp-feed.php" blog japan travel the-ruby-ronin)
              ("http://sachachua.com/blog/feed" blog emacs sachachua)
              ("http://sdegutis.com/blog/atom.xml" blog dev StevenDegutis)
              ("http://spensertruex.com/rss.xml" blog emacs SpenserTruex)
              ("http://tangent.libsyn.com" blog money  ChristopherRyan)
              ("http://tech.memoryimprintstudio.com/feed" blog emacs MemoryImprintStudio)
              ("http://thefirestarter.co.uk/feed" blog money FireStarter)
              ("http://trey-jackson.blogspot.com/feeds/posts/default" blog emacs TreyJackson)
              ("http://tromey.com/blog/?feed=rss2" blog emacs TheCliffsOfInanity)
              ("http://ukfipod.space/feed" blog money UKFIPod)
              ("http://www.arcadianvisions.com/blog/rss.xml" blog emacs arcadianvisions)
              ("http://www.badykov.com/feed.xml" blog emacs KrakenOfThought)
              ("http://www.brool.com/index.xml" blog emacs Brool)
              ("http://www.gonsie.com/blorg/feed.xml" blog emacs)
              ("http://www.holgerschurig.de/index.xml" blog emacs HolgerSchurig)
              ("http://www.jesshamrick.com/atom.xml" blog emacs JessHamrick)
              ("http://www.modernemacs.com/index.xml" blog emacs ModernEmacs)
              ("http://www.moneyforthemoderngirl.org/feed" blog money MoneyForTheModernGirl)
              ("http://www.msziyou.com/feed/" blog money ZiYou)
              ("http://www.sastibe.de/index.xml" blog emacs SebastianSchweer)
              ("http://www.thefrugalcottage.com/feed" blog money FrugalCottage)
              ("http://www.thisiscolossal.com/feed" blog art Colossal)
              ("http://zzamboni.org/index.xml" blog hammerspoon dev Diego-Martín-Zamboni)
              ("https://3652daysblog.wordpress.com/feed" blog money 3652DaysBlog)
              ("https://affordanything.com/blog/feed" blog money AffordAnything)
              ("https://ambrevar.xyz/rss.xml" blog emacs PierreNeidhardt)
              ("https://aqeel.cc/feed.xml" blog emacs AqeelAkber)
              ("https://arenzana.org/feed" blog emacs Isma)
              ("https://babbagefiles.xyz/index.xml" blog emacs BabbageFiles)
              ("https://barnacl.es/rss" startup Barnacles)
              ("https://bitmia.com/rss" money Bitmia)
              ("https://blog.aaronbieber.com/feed.xml" blog emacs AaronBieber)
              ("https://blog.binchen.org/rss.xml" blog emacs BinChen)
              ("https://blog.burntsushi.net/index.xml" blog dev BurnedSushi)
              ("https://blog.danielgempesaw.com/rss" blog emacs DanielGempesaw)
              ("https://blog.laurentcharignon.com/post/index.xml" blog emacs LaurentCharingnon)
              ("https://blog.moneysavingexpert.com/blog.rss" blog money MoneySavingExpert MartinLewis)
              ("https://changelog.com/feed" blog dev news JohnGoerzen)
              ("https://changelog.complete.org/feed" blog emacs JohnGoerzen)
              ("https://chaoticlab.io/feed.xml" blog emacs ChaoticLab)
              ("https://colelyman.com/index.xml" blog emacs ColeLyman)
              ("https://copyninja.info/feeds/all.atom.xml" blog dev copyninja)
              ("https://curiousprogrammer.wordpress.com/feed" blog emacs ACuriousProgrammer)
              ("https://d12frosted.io/atom.xml" blog emacs d12frosted)
              ("https://ddavis.io/index.xml" blog emacs )
              ("https://deliberatelivinguk.wordpress.com/feed/" blog money DeliberateLivingUK)
              ("https://dev.to/feed" blog dev DevTo)
              ("https://developer.atlassian.com/blog/feed.xml" blog emacs attlasian)
              ("https://dmolina.github.io/index.xml" blog emacs DanielMolina)
              ("https://drfire.co.uk/feed" blog money DrFire)
              ("https://dschrempf.github.io/index.xml" blog emacs DominikSchrempf)
              ("https://elephly.net/feed.xml" blog emacs Elephly)
              ("https://emacs-doctor.com/feed.xml" blog emacs emacs-doctor)
              ("https://emacsist.github.io/index.xml" blog emacs emacsist)
              ("https://emacsnotes.wordpress.com/feed" blog emacs EmacsNotes)
              ("https://ericasadun.com/feed" blog swift ios EricaSadun)
              ("https://erick.navarro.io/index.xml" dev emacs ErickNavarro)
              ("https://etienne.depar.is/a-ecrit/feed/atom" blog emacs EtienneDeparis)
              ("https://feeds.feedburner.com/codinghorror" blog dev Coding-Horror)
              ("https://fireinlondon.wordpress.com/feed" blog money FireInLondon)
              ("https://firevlondon.com/feed" blog money FireVLondon)
              ("https://firevlondon.com/feed/" blog money FIREvsLondon)
              ("https://frugalfoxes.home.blog/feed" blog money FrugalFoxes)
              ("https://fuco1.github.io/rss.xml" blog emacs Fuco)
              ("https://ghuntley.com/rss" blog dev ghuntley)
              ("https://github.crookster.org/feed.xml" blog dev emacs Crook)
              ("https://hacks.mozilla.org/feed" blog dev Mozilla)
              ("https://harryrschwartz.com/atom.xml" bloc emacs HarryRSchwartz)
              ("https://hasanyavuz.ozderya.net/?feed=rss2" blog emacs HasanYavuz)
              ("https://hbfs.wordpress.com/feed" blog emacs StevenPigeon)
              ("https://howtosavecash.co.uk/feed" blog money HowToSaveCash)
              ("https://humbledollar.com/blog/feed" blog money HumbleDollar)
              ("https://iloveemacs.wordpress.com/feed" blog emacs ILoveEmacs)
              ("https://increment.com/feed.xml" blog dev Increment)
              ("https://indeedably.com/feed/" blog money InDeedABly)
              ("https://jarss.github.io/TAONAW/index.xml" blog emacs Jarss)
              ("https://jvns.ca/atom.xml" blog emacs JuliaEvans)
              ("https://kdecherf.com/feeds/blog.atom.xml" blog dev kdecherf-blog)
              ("https://kdecherf.com/feeds/le-kdecherf.atom.xml" blog dev kdecherf)
              ("https://keyholesoftware.com/feed" blog emacs keyhole)
              ("https://krsoninikhil.github.io/atom.xml" blog emacs NikhilSoni)
              ("https://lars.ingebrigtsen.no/feed" blog emacs LarsIngebrigtsen)
              ("https://librelounge.org/rss-feed.rss" blog dev LibreLounge)
              ("https://linuxhint.com/feed" blog emacs LinuxHint)
              ("https://lobste.rs/rss" blog dev Lobsters)
              ("https://manuel-uberti.github.io/feed.xml" blog emacs ManuelUberti)
              ("https://martinralbrecht.wordpress.com/feed" blog emacs MartinAlbrecht)
              ("https://martinralbrecht.wordpress.com/feed" blog emacs MartinralBrecht)
              ("https://matt.hackinghistory.ca/feed/" blog emacs MattPrice)
              ("https://medium.com/feed/@tasshin" blog emacs meditation MichaelFogleman)
              ("https://mhaffner.github.io/index.xml" blog emacs MatthewHaffner)
              ("https://moneytothemasses.com/feed" money blog MoneyToTheMasses)
              ("https://news.ycombinator.com/rss" hackernews tech)
              ("https://nickdrozd.github.io/feed.xml" blog emacs NicholasDrozd)
              ("https://notanumber.io/feed.xml" blog emacs NotANumber)
              ("https://ogbe.net/blog.xml" blog emacs dev DennisOgbe)
              ("https://palikar.github.io/index.xml" blog emacs StanislavArnaudov)
              ("https://people.gnome.org/~federico/blog/feeds/all.atom.xml" emacs FedericoMenaQuintero)
              ("https://piware.de/post/index.xml" blog dev MartinPitt)
              ("https://punchagan.muse-amuse.in/feed.xml" blog emacs Punchagan)
              ("https://ryanfb.github.io/etc/feed.xml" blog dev RyanBaumann)
              ("https://ryanholiday.net/feed/" blog meditation health RyanHoliday)
              ("https://ryanholiday.net/feed/atom" blog emacs StringsNote)
              ("https://sam217pa.github.io/index.xml" blog emacs BacterialFinches)
              ("https://sciencebasedmedicine.org/feed" blog medicine health ScienceBasedMedicine)
              ("https://scripter.co/posts/index.xml" blog emacs dev)
              ("https://seeknuance.com/feed" blog emacs SeekNuance)
              ("https://simplelivingsomerset.wordpress.com/feed/" blog money SimpleLivingSomerset)
              ("https://swiftnews.curated.co/issues.rss" blog swift ios ShiftNewsCurated)
              ("https://swiftweekly.github.io/feed.xml" blog swift ios SwiftWeekly)
              ("https://theescapeartist.me/feed/" blog money EscapeArtist)
              ("https://thesavingninja.com/feed" blog money SavingNinja)
              ("https://two-wrongs.com/atom" blog emacs TwoWrongs)
              ("https://valignatev.com/index.xml" blog emacs ValentinIgnatev)
              ("https://vicarie.in/archive.xml" blog emacs NarendraJoshi)
              ("https://vxlabs.com/feed" blog emacs VXLabs)
              ("https://webgefrickel.de/blog/feed" blog dev SteffenRademacker)
              ("https://wincent.com/blog.rss" blog dev wincent)
              ("https://write.as/dani/feed" blog emacs Daniel)
              ("https://writequit.org/posts.xml" blog emacs writequit)
              ("https://www.baty.net/index.xml" blog emacs JackBaty)
              ("https://www.bofh.org.uk/post/index.xml" blog emacs PiersCawley)
              ("https://www.bogleheads.org/forum/feed?sid=a8ec975abd90862320b3ca6ac4da7f3c" money BoggleHeadsInvesting)
              ("https://www.bogleheads.org/forum/feed?sid=f11d3ab0a9c9bb6211c46ac2e4f8ee23" money BoggleHeadsPersonalFinance)
              ("https://www.bytedude.com/feed.xml" blog emacs MarcinS)
              ("https://www.campfirefinance.com/feed" blog money CampFireFinance)
              ("https://www.choosefi.com/category/podcast-episodes/feed" blog money ChoosefiPodcasts)
              ("https://www.choosefi.com/feed/" blog money Choosefi)
              ("https://www.designboom.com/feed" blog art DesignBoom)
              ("https://www.designernews.co/?format=atom" blog design DesignerNews)
              ("https://www.drweil.com/blog/health-tips/feed" blog health healthTips DrWeil)
              ("https://www.drweil.com/blog/spontaneous-happiness/feed" blog health happinessTips DrWeil)
              ("https://www.foxymonkey.com/feed" blog money FoxMonkey)
              ("https://www.fugue.co/blog/rss.xml" blog emacs Fugue)
              ("https://www.getrichslowly.org/feed" blog money GetRichSlowly)
              ("https://www.hasecke.eu/index.xml" blog emacs hasecke)
              ("https://www.ict4g.net/adolfo/site.atom" blog dev Adolfo)
              ("https://www.johndcook.com/blog/feed" blog emacs JohnDCook)
              ("https://www.madfientist.com/feed/" blog money MadFientist)
              ("https://www.moneysavingexpert.com/news/feeds/news.rss" blog money MoneySavingExpert news)
              ("https://www.ogre.com/blog/feed" blog dev Ogre)
              ("https://www.producthunt.com/feed" blog products ProductHunt)
              ("https://www.raptitude.com/feed" blog lifestyle Rapititude)
              ("https://www.reddit.com/r/UKPersonalFinance/.rss" social reddit money UKPersonalFinanceSubreddit)
              ("https://www.reddit.com/r/investing/.rss" social reddit money InvestingSubreddit)
              ("https://www.romanzolotarev.com/rss.xml" blog bsd dev RomanZolotarev)
              ("https://www.steventammen.com/index.xml" blog emacs StevenTammen)
              ("https://www.swiftbysundell.com/posts?format=RSS" blog swift SwiftBySundell)
              ("https://www.with-emacs.com/rss.xml" blog emacs WithEmacs)
              ("https://youngfiguy.com/feed" blog money YoungFIGuy)
              ("https://zhangda.wordpress.com/feed" blog emacs DaZhang)
              ("https://zudepr.co.uk/feed" blog money Zude)
              ))

  (ar/csetq elfeed-search-title-max-width 120)

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
        (if (called-interactively-p)
            (insert (if (listp return)
                        (s-join " " return)
                      return))
          return)))))
