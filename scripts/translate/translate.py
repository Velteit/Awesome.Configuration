#!/usr/bin/python

from googletrans import Translator;
import sys, getopt;

class Input:
    def __init__(self, src, dest, text):
        self.__src = src;
        self.__dest = dest;
        self.__text = text;

    def src(self):
        return self.__src;

    def dest(self):
        return self.__dest;

    def text(self):
        return self.__text;


def main(inp):
    translator = Translator();

    print(inp.src());
    print(inp.dest());
    print(inp.text());
    print(translator.translate(inp.text(), src=inp.src(), dest=inp.dest()));

if __name__ == "__main__":
    main(Input(sys.argv[1], sys.argv[2], sys.argv[3]));
