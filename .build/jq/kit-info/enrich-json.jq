[
    ( .[] | to_entries[] | . += {
        "type":"\(.key |
            if contains("ip") then "ip" else
                if contains("url") then "url" else
                    if contains("pw") then "cred" else
                        if contains("pem") then "cred"  else
                            if contains("cmd") then "cmd" else
                                if contains("name") then "username" else
                                    if contains("domain") then "domain" else
                                        if contains("rand_string") then "cred" else
                                            if contains("secret") then "cred" else
                                                if contains("id") then "id" else
                                                    if contains("corelight_community") then "id" else
                                                        if contains("branch") then "kit" else
                                                            if contains("kit_num") then "kit" else
                                                                if contains("role_arn") then "id" else
                                                                    if contains("mfa_serial") then "cred" else
                                                                        if contains("source_profile") then "id" else
                                                                            if contains("aws_conf_region") then "kit" else
                                                                                if contains("aws_acct_alias") then "kit" else
                                                                                    if contains("team") then "uncategorized" else
                                                                                        "uncategorized"
                                                                                    end
                                                                                end
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end )",
        "groups": (.key |
        if contains("bastion") then ["bastion"] else
            if contains("hx") then ["hx","hfs"] else
                if contains("iris") then ["iris","hfs"] else
                    if contains("cx") then ["cx"] else
                        if contains("cluster_mgr") then ["splunk", "hfs", "cfs", "nfs"] else
                            if contains("search") then ["splunk", "hfs", "cfs", "nfs"] else
                                if contains("indexer") then ["splunk", "hfs", "cfs", "nfs"] else
                                    if contains("forwarder") then ["splunk", "hfs", "cfs", "nfs"] else
                                        if contains("splunk") then ["splunk", "hfs", "cfs", "nfs"] else
                                            if contains("corelight") then ["corelight", "nfs"] else
                                                if contains("hfs") then ["kit", "hfs"] else
                                                    if contains("ssh") then ["kit", "hfs", "cfs", "nfs"] else
                                                        if contains("aws") then ["kit", "aws"] else
                                                            if contains("team") then ["kit", "hfs", "cfs", "nfs"] else
                                                                if contains("kit") then ["kit", "hfs", "cfs", "nfs"] else
                                                                    if contains("domain") then ["kit", "hfs", "cfs", "nfs"] else
                                                                        if contains("branch") then ["kit", "hfs", "cfs", "nfs"] else
                                                                            if contains("rand_string") then ["kit", "hfs", "cfs", "nfs"] else
                                                                            "uncategorized"
                                                                            end
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    } )
]
