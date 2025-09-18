[.[].dependencies[]] | group_by(.) | map({ "\(.[0])" : length}) | add
