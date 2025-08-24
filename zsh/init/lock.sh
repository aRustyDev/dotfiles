# GOALS:
# 1. Has .paths.yaml changed?
# 2. Has PATH changed?
# 3. Has $ZDOTDIR/init.zsh changed?
update_lock() {

    while (( $# > 0 )); do
    case "$1" in
        --input)
        input_file="$2"
        shift 2
        ;;
        --output)
        output_dir="$2"
        shift 2
        ;;
        --type)
        type="$2"
        shift 2
        ;;
        *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac
    done

    case "$type" in
        --input)
        input_file="$2"
        shift 2
        ;;
        --output)
        output_dir="$2"
        shift 2
        ;;
        --type)
        type="$2"
        shift 2
        ;;
        *)
        echo "Unknown option: $1"
        return 1
        ;;
    esac

    SUM=$(sha256sum $1)
    echo '{"'$1'": "'$SUM'"}' | jq '.' $input_file > $output_file
}

check_lock() {
    SUM=$(sha256sum $1)
    echo '{"sum": "'$SUM'", "state": "locked"}' | jq '.' $input_file > $output_file
}
