{# Simple Example: #}
duply:
  lookup:
    profiles:
      myprof:
        conf:
          GPG_KEYS_ENC: '<pubkey1>,<pubkey2>,...'
          GPG_KEY_SIGN: '<prvkey>'
          GPG_PW_SIGN: '<signpass>'
          GPG_OPTS: ''
          GPG_TEST: 'disabled'
          TARGET_USER: '_backend_username_'
          TARGET_PASS: '_backend_password_'
          FILENAME: '.duplicity-ignore'
          MAX_AGE: 1M
          MAX_FULL_BACKUPS: 1
          MAX_FULLBKP_AGE: 1M
          VOLSIZE: 50
          VERBOSITY: 5
          TEMP_DIR: /tmp
          ARCH_DIR: /some/space/safe/.duply-cache
          DUPL_PARAMS: "$DUPL_PARAMS --put_your_options_here "


{# Example using optional <https://github.com/bechtoldt/saltstack-crypto-formula>: #}
duply:
  lookup:
    sls_include:
      - crypto.gpg
    profiles:
      common:
        conf:
          GPG_KEY: 'F1D35B33'
          GPG_PW: 'password'
          VERBOSITY: 5
      myprof_example2:
        conf:
          TARGET: 'file:///var/backups/duplytest'
          SOURCE: '/var/'
      myprof_example3:
        conf:
          TARGET: 'file:///var/backups/duplytest2'
          SOURCE: '/usr/'
          VERBOSITY: 3
        excludes:
          - '/usr/local'
          - '- /usr/local/doc'
          - '/usr/local/bin'
        dupl_params:
          - "--exclude-regexp '${SOURCE}/.*/priv/nobackup/.*'"
        pre: {}
        post: {}

crypto:
  gpg:
    keys:
      duply_pub_key:
        path: /root/.duply/myprof_example2/gpgkey.F1D35B33.pub.asc
        content: |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          ...
          ...
          ...
          -----END PGP PUBLIC KEY BLOCK-----
      duply_prv_key:
        path: /root/.duply/myprof_example2/gpgkey.F1D35B33.sec.asc
        type: private
        mode: 640
        content: |
          -----BEGIN PGP PRIVATE KEY BLOCK-----
          ...
          ...
          ...
          -----END PGP PRIVATE KEY BLOCK-----
