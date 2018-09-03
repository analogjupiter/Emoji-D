/+
                    Copyright 0xEAB 2018.
     Distributed under the Boost Software License, Version 1.0.
        (See accompanying file LICENSE_1_0.txt or copy at
              https://www.boost.org/LICENSE_1_0.txt)
 +/
import std.stdio : File, stderr, stdout;
import std.string;

int main(string[] args)
{
    if (args.length < 2)
    {
        stderr.writeln("E:\tNo emoji-list.html specified.");
        return 1;
    }

    if (args.length < 3)
    {
        stderr.writeln("E:\tNo target path specified specified.");
        return 1;
    }

    auto input = File(args[1], "r");

    Collection cl;
    Section section;
    SubSection subSection;
    Emoji emoji;

    foreach (line; input.byLine)
    {
        auto i = line.indexOf("<tr><th colspan='15' class='bighead'><a href='#");
        if (i >= 0)
        {
            // new section
            immutable snA = line.indexOf(">", 47) + 1;
            immutable snB = line.indexOf("</a>", snA);
            auto sn = line[snA .. snB];
            section = new Section();
            section.name = sn.dup;
            cl ~= section;
        }
        else
        {
            i = line.indexOf("<tr><th colspan='15' class='mediumhead'><a href='#");
            if (i >= 0)
            {
                // new subsection
                immutable ssnA = line.indexOf(">", 50) + 1;
                immutable ssnB = line.indexOf("</a>", ssnA);
                auto ssn = line[ssnA .. ssnB];
                subSection = new SubSection();
                subSection.name = ssn.dup;
                section.subSections ~= subSection;
            }
            else
            {
                i = line.indexOf("<td class='chars'>");
                if (i >= 0)
                {
                    // emoji char
                    immutable ecA = 18;
                    immutable ecB = line.indexOf("</td>");
                    auto ec = line[ecA .. ecB];
                    emoji = new Emoji();
                    emoji.char_ = ec.dup;
                }
                else
                {
                    i = line.indexOf("<td class='name'>");
                    if (i >= 0)
                    {
                        // emoji name
                        immutable enA = 17;
                        immutable enB = line.indexOf("</td>");
                        auto en = line[enA .. enB];
                        emoji.name = en.dup;
                        subSection.emojis ~= emoji;
                    }
                }
            }
        }
    }

    File target = (args[2] == "-") ? stdout : File(args[2], "w");
    cl.write(target);
    return 0;
}

void write(Collection c, File target)
{
    foreach (Section s; c)
    {
        auto sn = s.name.fixAmp.toCamelCase!true;
        target.writeln("enum ", sn, " {");
        foreach (SubSection ss; s.subSections)
        {
            auto ssn = ss.name.fixAmp;
            target.writeln("    // ", ssn);
            foreach (Emoji e; ss.emojis)
            {
                auto en = e.name.fixNewMarker.fixSpecialChars.toCamelCase
                    .fixStartingWithDigit.fixReserved;
                target.writeln("    ", en, " = \"", e.char_, "\",");
            }
        }
        target.writeln("}");
    }
}

char[] fixAmp(char[] input)
{
    pragma(inline, true);
    return input.replace("&amp;", "and");
}

char[] fixSpecialChars(char[] input)
{
    pragma(inline, true);
    return input.replace("#", "Hash").replace("*", "Asterisk");
}

char[] fixNewMarker(char[] input)
{
    pragma(inline, true);
    return input.replace("⊛", "");
}

char[] fixStartingWithDigit(char[] input)
{
    import std.ascii : isDigit;

    pragma(inline, true);
    return (input[0].isDigit) ? 'n' ~ input : input;
}

char[] fixReserved(char[] input)
{
    pragma(inline, true);
    return (input == "package") ? input ~ '_' : input;
}

char[] toCamelCase(bool usePascalCaseInstead = false)(char[] input)
{
    import std.ascii : isAlphaNum;
    import std.uni : toLower, toUpper;

    char[] inp = input.strip;
    char[] output;
    bool nextUpper;

    static if (usePascalCaseInstead)
    {
        output ~= inp[0].toUpper;
    }
    else
    {
        output ~= inp[0].toLower;
    }

    foreach (c; inp[1 .. $])
    {
        if (!c.isAlphaNum)
        {
            nextUpper = true;
        }
        else if (nextUpper)
        {
            output ~= c.toUpper;
            nextUpper = false;
        }
        else
        {
            output ~= c;
        }
    }

    return output;
}

alias Collection = Section[];

final:
class Emoji
{
    char[] char_;
    char[] name;
}

class SubSection
{
    char[] name;
    Emoji[] emojis;
}

class Section
{
    char[] name;
    SubSection[] subSections;
}
