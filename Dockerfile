# syntax=docker/dockerfile:1.7

# Fetch the two upstream sources that Debian does not package, pinned by checksum. Both are
# pure Perl, so no compiler or `make` is needed: the files are copied straight into place. Being
# architecture-independent, this stage runs once on the native build platform, not under emulation.
FROM --platform=$BUILDPLATFORM debian:trixie-slim AS fetch

ADD --checksum=sha256:7d5c3c2d4f9b657a8b1dce7f5e2cbbe02ada2e97c72f3a0304bf3c99d084b045 \
  https://cpan.metacpan.org/authors/id/K/KB/KBAUCOM/Term-Animation-2.6.tar.gz /tmp/
ADD --checksum=sha256:1b08c6613525e75e87546f4e8984ab3b33f1e922080268c749f1777d56c9d361 \
  https://robobunny.com/projects/asciiquarium/asciiquarium.tar.gz /tmp/

RUN mkdir -p /out/perl /out/bin \
  && tar -xzf /tmp/Term-Animation-2.6.tar.gz -C /tmp \
  && tar -xzf /tmp/asciiquarium.tar.gz -C /tmp \
  && cp -r /tmp/Term-Animation-2.6/lib/Term /out/perl/ \
  && install -m 0755 /tmp/asciiquarium_1.1/asciiquarium /out/bin/asciiquarium


FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive \
  LANG=C.UTF-8 \
  TERM=xterm-256color \
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

# One layer, no recommends, apt lists dropped. hollywood's useful recommends (the panes it
# animates) are listed explicitly so heavy, irrelevant ones (atop, plocate, ssh) stay out.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    perl libcurses-perl \
    libaa-bin cmatrix toilet lolcat \
    hollywood byobu tmux \
    apg bmon bsdextrautils ccze htop jp2a moreutils speedometer tree \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /usr/share/doc/* /usr/share/man/*

COPY --from=fetch /out/perl/ /usr/local/lib/site_perl/
COPY --from=fetch /out/bin/asciiquarium /usr/local/bin/asciiquarium

RUN cat >> /root/.bashrc <<'EOF'
toilet --metal E T S Rox.
echo '> asciiquarium'
echo '> aafire'
echo '> cmatrix'
echo '> hollywood'
EOF

CMD ["bash"]
