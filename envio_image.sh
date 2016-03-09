#!/bin/bash -e

time=$(date +%Y-%m-%d)
DIR="$PWD"

./RootStock-NG.sh -c envio-wheezy-console.conf

debian_console_stable="debian-7.9-console-armhf-${time}"
archive="xz -z -8 -v"

cat > ${DIR}/deploy/gift_wrap_final_images.sh <<-__EOF__
#!/bin/bash

pre_generic_img () {
        if [ -d ./\${base_rootfs} ] ; then
                rm -rf \${base_rootfs} || true
        fi

        if [ -f \${base_rootfs}.tar.xz ] ; then
                tar xf \${base_rootfs}.tar.xz
        else
                tar xf \${base_rootfs}.tar
        fi
}

generic_img () {
        cd \${base_rootfs}/
        sudo ./setup_sdcard.sh \${options}
        mv *.img ../
        cd ..
}

post_generic_img () {
        if [ -d ./\${base_rootfs} ] ; then
                rm -rf \${base_rootfs} || true
        fi

        if [ ! -f \${base_rootfs}.tar.xz ] ; then
                ${archive} \${base_rootfs}.tar
        fi
}

compress_img () {
        if [ -f \${wfile} ] ; then
                #prevent xz warning for 'Cannot set the file group: Operation not permitted'
                sudo chown \${UID}:\${GROUPS} \${wfile}
                ${archive} \${wfile}
        fi
}

###console images: (also single partition)
base_rootfs="${debian_console_stable}"
pre_generic_img

options="--img-2gb BBB-eMMC-flasher-\${base_rootfs} --dtb beaglebone --enable-systemd --bbb-flasher --bbb-old-bootloader-in-emmc --hostname envio-beaglebone"
generic_img
#options="--img-2gb bone-\${base_rootfs}             --dtb beaglebone --enable-systemd --bbb-old-bootloader-in-emmc --hostname beaglebone"
#generic_img

###archive *.tar

base_rootfs="${debian_console_stable}"
post_generic_img

###archive *.img
wfile="BBB-eMMC-flasher-${debian_console_stable}-2gb.img"
compress_img
#wfile="bone-${debian_console_stable}-2gb.img"
#compress_img

__EOF__

chmod +x ${DIR}/deploy/gift_wrap_final_images.sh
