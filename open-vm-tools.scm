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
  #:use-module (gnu packages file)
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
    (version "11.0.0")
    (source (origin
              (method git-fetch)
              (uri (git-reference
                     (url "https://github.com/vmware/open-vm-tools.git")
                     (commit (string-append "stable-" version))))
              (file-name (git-file-name name version))
              (sha256
                (base32
                  "1q0gb5zibx9lhyvx35vhm2sjldrsr0c8hkcfaxqiv948cnv41i6x"))))
    (build-system gnu-build-system)
    (arguments
      ;; TODO: Add ability to optionally configure with/without X "--without-x"
      `(#:make-flags (let ((out (assoc-ref %outputs "out")))
                       (list
                         (string-append "LDFLAGS=-Wl,-rpath=" out "/lib")
                         )
                       )
        #:phases
        (modify-phases %standard-phases
                       (add-after `unpack `chdir
                                  (lambda _ (chdir "open-vm-tools") #t))
                       (add-before 'configure 'fix-ldconfig
                                   (lambda _
                                     (substitute* "configure"
                                       (("ldconfig") "true"))
                                     (substitute* "m4/libtool.m4"
                                       (("ldconfig") "true"))
                                     #t))
                       (replace 'configure
                         (lambda* (#:key outputs #:allow-other-keys)
                           (let ((out (assoc-ref outputs "out")))
                             (invoke "./configure"
                                     "--without-kernel-modules"
                                     (string-append "--prefix=" out)
                                     (string-append "--with-udev-rules-dir="
                                                    out "/lib/udev/rules.d")
                                     ;; Package not in GUIX
                                     "--without-dnet"
                                     ;; TODO fix eudev install path
                                     "SHELL=sh")
                             )))
                       (replace 'install
                         (lambda* (#:key outputs #:allow-other-keys)
                           (let ((out (assoc-ref outputs "out")))
                             (invoke "make" "install"
                                     ;; Needed because we don't want /usr/local
                                     ;; prefix before lib, bin, etc.
                                     "prefix="
                                     "UDEVRULESDIR=/lib/udev/rules.d"
                                     (string-append "DESTDIR=" out)
                                     )
                             )))
       )))
    (native-inputs
     `(("autoconf" ,autoconf-wrapper)
       ("automake" ,automake)
       ("libtool" ,libtool)
       ("gcc-toolchain" ,gcc-toolchain)
       ("pkg-config" ,pkg-config)
       ("file" ,file)
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
