#!/usr/bin/python3
import yaml
import sys


def edit_yaml(yaml_file, key, pat, repl):
    s = open(yaml_file, "r")
    y = yaml.safe_load(s)
    y['game'][key] = y['game'][key].replace(pat, repl)
    s.close()
    d = open(yaml_file, "w")
    d.write(yaml.safe_dump(y))
    d.close()


if __name__ == '__main__':
    edit_yaml(
        sys.argv[1],
        sys.argv[2],
        sys.argv[3],
        sys.argv[4],
    )
