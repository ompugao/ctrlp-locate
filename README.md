# ctrlp-locate
locate and open it via ctrlp.vim!

# Installation
- use your favorite method.
````
Plug 'ompugao/ctrlp-locate'
Bundle 'ompugao/ctrlp-locate'
NeoBundle 'ompugao/ctrlp-locate'
````

# Usage
- call command:
````
:CtrlPLocate
````
- there will be no entry. it's fine.
- and then, input whatever word you want to search. for example:
````
>>> test
````
- then, press \<Ctrl-d\>
````
> /boot/grub/x86_64-efi/setjmp_test.mod
> /boot/grub/x86_64-efi/pbkdf2_test.mod
> /boot/grub/x86_64-efi/legacy_password_test.mod
> /boot/grub/x86_64-efi/functional_test.mod
> /boot/grub/x86_64-efi/exfctest.mod
> /boot/grub/x86_64-efi/div_test.mod
> /boot/grub/x86_64-efi/cmdline_cat_test.mod
> /boot/memtest86+_multiboot.bin
> /boot/memtest86+.elf
> /boot/memtest86+.bin
````
- Yes! select whatever you want to open!
  
## Gif
![](https://raw.githubusercontent.com/wiki/ompugao/ctrlp-locate/imgs/ctrlp-locate.gif)

# Configuration
- *g:ctrlp_locate_max_candidates* : set the maximum number of files you search. for example:
````
let g:ctrlp_locate_max_candidates=30
````
# Bugs(?)

- do not set g:ctrlp_key_loop to 1. It does not work somehomw.
````
let g:ctrlp_key_loop=0
````

