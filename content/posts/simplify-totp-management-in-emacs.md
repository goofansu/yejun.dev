---
title: "Simplify TOTP management in Emacs"
author: ["Yejun Su"]
date: 2023-09-13T02:54:00+08:00
tags: ["emacs", "totp"]
draft: false
---

> Time-based one-time password (TOTP) is a computer algorithm that generates a
> one-time password (OTP) that uses the current time as a source of uniqueness.
>
> -- [Wikipedia](https://en.wikipedia.org/wiki/Time-based_one-time_password)

[password-store-otp](https://github.com/volrath/password-store-otp.el/) is an Emacs package which provides functions to
interact with the [pass-otp](https://github.com/tadfisher/pass-otp/) extension for [pass](https://www.passwordstore.org/). There are two
functions that insert or append the OTP key URI to a selected pass entry. But
it's not that easy because websites generally provide QR Code or secret key,
which requires me to compose the OTP key URI manually.

To simplify the process, I created two corresponding functions based on those in
password-store-otp:

```emacs-lisp
(defun yejun/password-store-otp-append (entry issuer secret)
  "Append to ENTRY the OTP-URI consisting of issuer and secret."
  (interactive (list (password-store-otp-completing-read)
                     (read-string "Issuer: ")
                     (read-passwd "Secret: " t)))
  (let* ((secret (replace-regexp-in-string "\\s-" "" secret))
         (otp-uri (format "otpauth://totp/totp-secret?secret=%s&issuer=%s" secret issuer)))
    (password-store-otp-add-uri 'append entry otp-uri)))

(defun yejun/password-store-otp-insert (entry issuer secret)
  "Insert a new ENTRY containing OTP-URI consisting of issuer and secret."
  (interactive (list (password-store-otp-completing-read)
                     (read-string "Issuer: ")
                     (read-passwd "Secret: " t)))
  (let* ((secret (replace-regexp-in-string "\\s-" "" secret))
         (otp-uri (format "otpauth://totp/totp-secret?secret=%s&issuer=%s" secret issuer)))
    (password-store-otp-add-uri 'insert entry otp-uri)))
```

When calling either function, it will prompt for the `issuer` and `secret`, then
compose an OTP key URI with the values in this format:
`otpauth://totp/totp-secret?secret=<secret>&issuer=<issuer>`, which saves manual
effort.

---

To keep it simpler, I extracted a function to create OTP key URI, so it can be
applied in more scenarios:

```emacs-lisp
(defun yejun/otp-key-uri (issuer secret)
  "Create and copy the OTP key URI consisting of issuer and secret."
  (interactive (list (read-string "Issuer: ")
                     (read-passwd "Secret: " t)))
  (let* ((secret (replace-regexp-in-string "\\s-" "" secret))
         (otp-uri (format "otpauth://totp/totp-secret?secret=%s&issuer=%s" secret issuer)))
    (kill-new otp-uri)
    (message "OTP key URI created and copied.")))
```

By calling the function, an OTP key URI is created and copied to the clipboard
for later use.
