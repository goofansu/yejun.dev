---
title: "Backup GnuPG private key"
author: ["Yejun Su"]
date: 2023-09-18T22:12:00+08:00
tags: ["security"]
draft: false
---

> [gpg-toolkit](https://github.com/goofansu/gpg-toolkit) is inspired by this article.

I'm using [GNU Privacy Guard](https://gnupg.org/) (GnuPG or GPG) in various
ways, such as [encrypting passwords]({{< relref "simplify-totp-management-in-emacs" >}}), decrypting
emails, signing git commits, and more. So it's time to find a way to backup the
GPG private key.

I asked GPT-4 for a method to keep the private key safe, and it tells me to
convert it to QR code and print it on the paper. That's a good idea! I'll start
from backup to a printable text, and then the QR code.


## Preparation {#preparation}

Before backup, you need to know your GPG key ID. Run this command:

```shell
gpg --list-keys --keyid-format long
```

It will list all the public keys in your system. Search your own key according
to this format `pub rsa2048/{YOUR KEY ID}`, the `{YOUR KEY ID}` part is your GPG
key ID.

Then export both the public and private key:

```shell
gpg --export-secret-keys {YOUR KEY ID} > private-key.gpg
gpg --export {YOUR KEY ID} > public-key.gpg
```


## Backup to printable text {#backup-to-printable-text}

One of the program to be used is [paperkey](https://github.com/dmshaw/paperkey/), it transforms the GPG private key to
a printable format. The usage is straightforward:

```shell
# backup
paperkey --secret-key private-key.gpg --output printable.txt
```

Keep in mind that you need both the **public key** and the **printable text** to restore
the private key:

```shell
# restore
paperkey --pubring public-key.gpg --secrets printable.txt --output restored-private-key.gpg
```


## Backup to QR code {#backup-to-qr-code}

The process is similar to the previous method, but it requires two more
programs: [qrencode](https://fukuchi.org/works/qrencode/) to create QR code and [zbar](https://github.com/mchehab/zbar) to read QR code. Generally
speaking, the more programs you rely on, the more friction you run into. But I
just tried it for fun:

```shell
# backup
paperkey --output-type raw --secret-key private-key.gpg | base64 | qrencode -o qrcode.png
```

With the **public key** and **QR code** in hand, you can restore the private key:

```shell
# restore
zbarimg qrcode.png | cut -d':' -f2 | base64 --decode | paperkey --pubring public-key.gpg --output restored-private-key.gpg
```
