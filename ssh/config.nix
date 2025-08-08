{ config, pkgs, ... }:

let
  # Paths to the original files
  file1 = ./.tmpl.;
  file2 = ./file2.txt;

  # Read the contents of the files
  content1 = builtins.readFile file1;
  content2 = builtins.readFile file2;

  # Merge contents (simple concatenation with newline)
  mergedContent = "${content1}
${content2}";

  # Create a temporary file with merged content using a derivation
  mergedFile = pkgs.runCommand "merged.config" {} ''
      Tmpl="ssh/.tmpl/config"
      op account add --address my.1password.com
      for file in `ls ssh/.tmpl/config/`; do \
        # Run `op inject` on the merged file to inject private values
        op inject -f -i ssh/.tmpl/config/$file -o ssh/config/$file; \
      done
      for file in `ls ssh/.tmpl/pubs/`; do \
        # Run `op inject` on the merged file to inject private values
        op inject -f -i ssh/.tmpl/pubs/$file -o ssh/pubs/$file; \
      done
      for file in `ls "$Tmpl" | grep -Eo "(cisco)|(blvd)"`; do \
        cat "$Tmpl/includes" "$Tmpl/$file"* "$Tmpl/default" > ssh/config/$file.merged; \
      done
  '';
in
{
  home.file.{
    "merged.config" = {
      source = mergedFile;
      target = "${config.dot.cfg.dir}/ssh/config";
    };
    # ssh pubs
  };
}
