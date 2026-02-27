init proj repo user:
    gt init
    bd init --prefix "{{ proj }}"
    gt rig add "{{ proj }}" "{{ repo }}"
    gt crew add "{{ user }}" --rig "{{ proj }}"
    # license setup
    # pre-commit setup
    # brewfile setup
