;;; feed-discovery-test.el --- Test for feed-discovery.el  -*- lexical-binding: t; -*-

(require 'feed-discovery)
(require 'ert)

(defmacro feed-discovery-test-with-buffer (content &rest body)
  "Eval BODY in a temp buffer which contains CONTENT."
  (declare (indent 1))
  `(with-temp-buffer
     (insert ,content)
     ,@body))


(ert-deftest feed-discovery--discover-feeds-in-region ()
  ;; discover an rss feed
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <link href=\"https://example.com/rss\" rel=\"alternate\" type=\"application/rss+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max))
      '("https://example.com/rss"))))

  ;; discover an atom feed
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <link href=\"https://example.com/atom\" rel=\"alternate\" type=\"application/atom+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max))
      '("https://example.com/atom"))))

  ;; discover a feed without base
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <link href=\"rss\" rel=\"alternate\" type=\"application/rss+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max)
                                                "https://example.com/")
      '("https://example.com/rss"))))

  ;; discover a feed without base but base element exists
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <base href=\"https://example.com/\" />
    <link href=\"rss\" rel=\"alternate\" type=\"application/rss+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max))
      '("https://example.com/rss"))))

  ;; discover a feed without protocol
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <link href=\"//example.com/rss\" rel=\"alternate\" type=\"application/rss+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max)
                                                "https://example.com/")
      '("https://example.com/rss"))))

  ;; discover a feed without protocol but base element exists
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <base href=\"https://example.com/\" />
    <link href=\"//example.com/rss\" rel=\"alternate\" type=\"application/rss+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max))
      '("https://example.com/rss"))))

  ;; discover feeds
  (feed-discovery-test-with-buffer "\
<html>
  <head>
    <link href=\"https://example.com/rss\" rel=\"alternate\" type=\"application/rss+xml\" />
    <link href=\"https://example.com/atom\" rel=\"alternate\" type=\"application/atom+xml\" />
  </head>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max))
      '("https://example.com/rss"
        "https://example.com/atom"))))

  ;; discover a feed from body element
  ;;
  ;; Target link elements are placed in the body element on some pages,
  ;; e.g. "https://www.youtube.com/channel/CHANNEL_ID".
  (feed-discovery-test-with-buffer "\
<html>
  <head>
  </head>
  <body>
    <link href=\"https://example.com/rss\" rel=\"alternate\" type=\"application/rss+xml\" />
  </body>
</html>"
    (should
     (equal
      (feed-discovery--discover-feeds-in-region (point-min) (point-max))
      '("https://example.com/rss")))))


;;; feed-discovery-test.el ends here
