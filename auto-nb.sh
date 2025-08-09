#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <ollama-model-name>"
  exit 1
fi

model="$1"
out="ollama-benchmarker.txt"

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

echo "Done - output written to $out"
