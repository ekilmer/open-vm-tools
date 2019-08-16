(define-module (gnu packages open-vm-tools)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system gnu)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages onc-rpc)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages check)
  )

(define-public open-vm-tools
  (package
    (name "open-vm-tools")
    (version "10.3.10")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/vmware/open-vm-tools.git")
                     (commit (string-append "stable-" version))))
              (file-name (git-file-name name version))
              (sha256
                (base32
                  "0x2cyccnb4sycrw7r5mzby2d196f9jiph8vyqi0x8v8r2b4vi4yj"))))
    (build-system gnu-build-system)
    (arguments
      ;; TODO: Add ability to optionally configure with/without X "--without-x"
      `(#:configure-flags '("--without-kernel-modules"
                            ;; TODO: Package not in GUIX yet
                            "--without-dnet")
        #:phases
        (modify-phases %standard-phases
                       (add-after `unpack `real-source
                                  (lambda _ (chdir "./open-vm-tools")))
                       (add-before 'configure 'fixgcc8
                                   (lambda _
                                     (unsetenv "C_INCLUDE_PATH")
                                     (unsetenv "CPLUS_INCLUDE_PATH")))
                       (add-before 'configure 'autoreconf
                                   (lambda _ (invoke "autoreconf" "-vfi") #t)))))
    (native-inputs
     `(("autoconf" ,autoconf-wrapper)
       ("automake" ,automake)
       ("libtool" ,libtool)
       ("gcc-toolchain", gcc-toolchain-8)
       ("pkg-config" ,pkg-config)
       ("cunit" ,cunit)))
    (inputs
     `(("kernel-headers" ,linux-libre-headers)
       ("pam" ,linux-pam)
       ("libmspack" ,libmspack)
       ("glib" ,glib)
       ("glib:bin" ,glib "bin")
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("gtk+" ,gtk+)
       ("gtkmm" ,gtkmm)
       ("fuse" ,fuse)
       ("openssl" ,openssl)
       ("libxml2" ,libxml2)
       ("xmlsec" ,xmlsec)
       ("libx11" ,libx11)
       ("libxext" ,libxext)
       ("libxinerama" ,libxinerama)
       ("libxi" ,libxi)
       ("libxrender" ,libxrender)
       ("libxrandr" ,libxrandr)
       ("libxtst" ,libxtst)
       ("libltdl" ,libltdl)
       ("libdrm" ,libdrm)
       ("libtirpc" ,libtirpc)
       ("udev" ,eudev)))
    (supported-systems '("x86_64-linux" "i686-linux"))
    (home-page "https://github.com/vmware/open-vm-tools")
    (synopsis
      "A set of services and modules that enable several features in
      VMware products for    better management of, and seamless user
      interactions with, guests.")
    (description
      "A set of services and modules that enable several features in
      VMware products for    better management of, and seamless user
      interactions with, guests.")
    (license license:gpl2+)))

open-vm-tools
