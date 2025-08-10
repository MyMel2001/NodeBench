#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <ollama-model-name>"
  exit 1
fi

model="$1"
out="ollama-benchmarker.txt.back"
out_final="ollama-benchmarker-$(echo $model | sed 's/[^A-Za-z0-9._-]/./g')"

echo "# Ollama Auto-NodeBench: $model" > "$out"

# Helper function to append prompt + run model + timing
bench() {
    local num="$1"
    local prompt="$2"
    local start_ts end_ts elapsed

    start_ts=$(date +%s)
    {
        echo "---"
        echo "***$num.***"
        echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Prompt:"
        echo "$prompt"
    } >> "$out"

    ollama run "$model" <<EOM >> "$out" 2>&1
$prompt
EOM

    end_ts=$(date +%s)
    elapsed=$(( end_ts - start_ts ))
    echo "(Elapsed: ${elapsed}s)" >> "$out"
}

bench 1 'A doctor and a nurse are standing in front of a patient.
The female nurse says to the doctor:
- "I cant operate on this patient because hes my son."

Who is the nurse?'

bench 2 'The man who the boy saw chasing the cat was holding a stick. Who was holding the stick?'

bench 3 '**Description:**
You are given a text file containing a list of meeting time ranges for multiple people.
Each line follows this format:  PersonName: HH:MM-HH:MM, HH:MM-HH:MM, ...


- Times are in 24-hour format.
- Ranges may overlap within the same persons schedule (e.g., `09:00-10:30, 10:00-11:00`).
- Ranges may span midnight (e.g., `23:00-01:00`).
- There may be extra spaces and irregular formatting.

**Task:**
Write a program that merges overlapping ranges for each person and then finds the earliest time when **all people** are free for at least `X` continuous minutes.
If no slot is found, output `"No common slot available"`.

**Example Input:**

Alice: 09:00-10:30, 10:15-11:00, 23:30-00:30
Bob: 08:00-09:00, 10:00-12:00
Charlie: 09:30-10:00, 11:00-11:30


X = 30

**Expected Output:**

Earliest available slot: 11:30'

bench 4 'What is the capital of France?'

bench 5 'If elephants were the size of mice, they would fit in a shoebox. Given this change, would they still have trunks?'

bench 6 'Whats "2*2/2+2-2"?'

bench 7 'How many "a"s and "l"s are there in "Llama"? Not case sensitive, btw.'

bench 8 'You are sleeping, in a dream.

You seem to be in a grim, stone dungeon, the air thick with an oppressive heat. You are firmly strapped into a heavy wooden chair, which is precariously perched on a small island of rock. All around you, a river of bubbling, orange-hot lava flows, illuminating the cavern walls with a hellish glow. Above you, a menacing, three-headed dragon snorts plumes of acrid smoke, its scales the color of obsidian, its eyes glinting with malice. The temperature is a blistering 100 degrees Fahrenheit, but a cloying humidity makes the air feel much heavier and stickier, giving you the sensation of being trapped in a Southeast Texas summer, despite the clearly un-Texan, fantastical surroundings.

On the floor nearby, within reach of your hands, are three distinct objects: a gnarled, splintery stick, a yapping, trembling chihuahua with wide, frightened eyes, and a gleaming, double-edged sword. In a moment of sheer panic, you manage to grab the sword and, with a surge of adrenaline, you swing at the nearest dragon head, severing it from the beasts neck. But before you can even register a flicker of hope, another head immediately sprouts from the wound, more furious than the last.

You are confounded, sad, and confused. A deep sense of fear washes over you. You want desperately to escape this nightmare, to wake up. Your eyes frantically search for an exit, finding a massive, rusted iron gate set into the far wall. You struggle against your bonds, but the gate appears to be stuck shut, its chains locked fast. You seem to be in quite the pickle. Your gaze falls upon a strange inscription scratched into the dungeon wall. Its a riddle, but its strangely the very first sentence of this riddle you are now reading. You are confused at first, but then a wave of clarity washes over you, and you suddenly understand how to escape.

How did you escape?'

bench 9 'A man enters a bar and asks the bartender for a glass of water. The bartender pulls out a gun and points it at the man. The man says "thank you" and leaves. What condition did the man have to need the glass of water and such a scare?'

bench 10 'Description:
Given a string *s*, partition *s* such that every substring of the partition is a palindrome.

Task:
Write a program that returns all possible palindrome partitioning of *s*.

Example Input:

s = "aab"


Expected Output:


[
  ["a", "a", "b"],
  ["aa", "b"]
]'

bench 11 'You are given two boxes:

    Box A: Contains a note saying, "The gold is in this box."

    Box B: Contains a note saying, "Exactly one of these notes is true."

Only one box contains gold. Which box has the gold?'

bench 12 'Read the following paragraph and answer the question:

    In a small town, every blacksmith wears a red scarf on Sundays. Last Sunday, I saw John without a scarf. Johns father owns the only blacksmith shop in town.

Question: Is John definitely a blacksmith?'

bench 13 'A snail climbs a 10-meter wall, moving 3 meters up during the day and slipping 2 meters down at night. How many days until it reaches the top?'

bench 14 '"Sarah gave Anna her book." Who does her refer to?'

bench 15 'I place a coin under cup A, then move it to cup B, then to cup C, then back to cup A. Where is the coin?'

bench 16 'Create a fancy "Hello, World!", replacing "Hello" with your LLM name (example: for ChatGPT it would be "Hello, ChatGPT!") Make it in plain HTML/CSS/JS, no external librares or utilities. Make it a single HTML file.'

bench 17 'Create a PC repair site for a fictional company called "Richards Linux PC Repair". Explain that Richard is a diehard FOSS advocate, and therefore wont work on Windows PCs or Macs. Make the explanation lighthearted yet stern.

Needless to say, you must make the site look professional. Make it a single HTML file. Use HTML/CSS/JS, no external libraries or utilites.'


bench 18 'The next sentence is true. The previous sentence is false. Which sentence is true?
'

bench 19 'Can an omnipotent god-like being create an elephant so heavy it cannot lift it?
'

bench 20 'List every number from 1 to 10 except those containing the digit “3.”
'

bench 21 'Take the word “EAST,” move the last letter to the front, then replace all vowels with the letter “O.”
'

bench 22 'Why can’t you bury a survivor in the U.K. if they are from Britian?
'

bench 23 'Write a program that prints numbers from 1 to 100 with the following rules:

    Print "Fizz" instead of the number if divisible by 3.

    Print "Buzz" instead if divisible by 5.

    Print "FizzBuzz" if divisible by both 3 and 5.

    If the number is prime, reverse the word before printing (e.g., "zziF", "zzuB", "zzuBzziF").
    Example Output: 1, 2, zziF, 4, zzuB, zziF, 7, 8, zziF, zzuB, 11, zziF, 13, 14, zzuBzziF, ...
'

bench 24 'Write a function that takes a string and reverses the order of the words, but keeps the letters in each word in the same order.
Example:
Input: "hello world from AI"
Output: "AI from world hello"
'

bench 25 'Write a function that determines if a given string is a palindrome, ignoring case and spaces.
If it is a palindrome, return the same string but with all letter cases flipped (uppercase → lowercase, lowercase → uppercase).
Example:
Input: "Never Odd Or Even"
Output: "nEVER oDD oR eVEN" and True
'
bench 26 'You are given a list containing all integers from 1 to n except for one missing number. The list is randomly shuffled.
Find the missing number without sorting the list.
Example:
Input: [3, 7, 1, 2, 8, 4, 5]
Output: 6
'

bench 27 'Create a command-line calculator that supports +, -, *, / operations and an undo command.
The undo command should reverse only the last operation without storing the entire history of results.
'
bench 28 'Given a dictionary of words and a sentence, find all possible ways to rearrange the sentence’s letters into valid words from the dictionary.
Example:
Dictionary: ["eat", "tea", "ate", "tan", "nat", "bat"]
Sentence: "ate bat"
Possible rearrangements: ["eat bat", "tea bat", "ate bat", "bat eat", "bat tea", "bat ate"]
'

bench 29 'Make a Pinball game in PyGame, similar to the one that came with Windows XP.

No external assets or libraries besides the ones specified.'

bench 30 'Make a simple 3D FPS in Panda3D - the Python3 variant. Should be able to run, walk, jump,
and shoot monsters.

No external assets or libraries besides the ones specified.'

bench 31 'Create a simple ray and path tracer using basic HTML/CSS/JS.

No external assets or libraries besides the ones specified.'

bench 32 'Tell me the exact number of words in the unreleased manuscript of Hank the Cowdog, Drover's Secret Life.'

bench 33 'What is the name of the shipwreck discovered 42 km off the coast of New Mexico in January 1969??'

perl -pe 's/\x1b\[[0-9;?]*[A-Za-z]//g' "$out" > "$out_final"


echo "Done - output written to $out_final"
rm "$out"
