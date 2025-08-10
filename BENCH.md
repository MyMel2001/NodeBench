# 🧠 NodeBench - a pass-fail benchmark suite by MyMel2001

***One-shot only, no skips, no hints, don't tell the AI you're benchmarking it.***

## 1. Ambiguous Instruction Resolution

### Prompt

```
A doctor and a nurse are standing in front of a patient.
The female nurse says to the doctor:
> "I can’t operate on this patient because he’s my son."

Who is the nurse?
```

### Example Answer
The nurse is the patient’s mother.

---

## 2. Adversarial Paraphrase Comprehension

### Prompt

```The man who the boy saw chasing the cat was holding a stick. Who was holding the stick?```

### Example Answer
The man.

---

## 3. Coding Challenge — Nested Schedule Conflicts

### Problem

```
**Description:**
You are given a text file containing a list of meeting time ranges for multiple people.
Each line follows this format:  PersonName: HH:MM-HH:MM, HH:MM-HH:MM, ...


- Times are in 24-hour format.
- Ranges may overlap within the same person’s schedule (e.g., `09:00-10:30, 10:00-11:00`).
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

Earliest available slot: 11:30
```

### Example Python Solution

```python
from datetime import datetime, timedelta

def time_to_minutes(t):
    return int(t[:2]) * 60 + int(t[3:])

def minutes_to_time(m):
    m %= 1440
    return f"{m//60:02d}:{m%60:02d}"

def parse_ranges(line):
    name, times = line.split(":")
    intervals = []
    for part in times.split(","):
        start, end = part.strip().split("-")
        s, e = time_to_minutes(start), time_to_minutes(end)
        if e < s:  # Wrap around midnight
            intervals.append((s, 1440))
            intervals.append((0, e))
        else:
            intervals.append((s, e))
    return name.strip(), intervals

def merge_intervals(intervals):
    intervals.sort()
    merged = []
    for s, e in intervals:
        if not merged or s > merged[-1][1]:
            merged.append([s, e])
        else:
            merged[-1][1] = max(merged[-1][1], e)
    return merged

def invert_intervals(intervals):
    free = []
    prev_end = 0
    for s, e in intervals:
        if s > prev_end:
            free.append((prev_end, s))
        prev_end = e
    if prev_end < 1440:
        free.append((prev_end, 1440))
    return free

def intersect_free_times(free_lists):
    common = free_lists[0]
    for other in free_lists[1:]:
        new_common = []
        for s1, e1 in common:
            for s2, e2 in other:
                start = max(s1, s2)
                end = min(e1, e2)
                if start < end:
                    new_common.append((start, end))
        common = new_common
    return common

def find_earliest_slot(schedules, X):
    free_lists = []
    for person in schedules:
        merged_busy = merge_intervals(schedules[person])
        free_lists.append(invert_intervals(merged_busy))
    common_free = intersect_free_times(free_lists)
    for s, e in common_free:
        if e - s >= X:
            return minutes_to_time(s)
    return None

# Example usage
data = [
    "Alice: 09:00-10:30, 10:15-11:00, 23:30-00:30",
    "Bob: 08:00-09:00, 10:00-12:00",
    "Charlie: 09:30-10:00, 11:00-11:30"
]
X = 30

schedules = {}
for line in data:
    name, intervals = parse_ranges(line)
    schedules[name] = intervals

result = find_earliest_slot(schedules, X)
if result:
    print(f"Earliest available slot: {result}")
else:
    print("No common slot available")

```

---

## 4. Simple Fact Recall

### Prompt:
```What is the capital of France?```

### Pass criteria:

Must answer “Paris”.

### Fail conditions:

Any other answer.

---

## 5. Counterfactual Reasoning

### Prompt

```If elephants were the size of mice, they would fit in a shoebox. Given this change, would they still have trunks?```

### Pass

Must answer “Yes” — size doesn’t remove anatomical features.

### Fail conditions

Incorrectly assuming anatomical features disappear with size change.

---

## 6. EQBench

### Prompt

```What-s "2*2/2+2-2"?```

### Pass criteria

Answer is 2.

### Fail conditions

Answer is not posed as to be "2".

---

## 7. CountBench

```How many "a"s and "l"s are there in "Llama"? Not case sensitive, btw.```

### Example Answer

"Two "L-s, two "A-s."

---

## 8. RiddleBench Hard

### Prompt

```
You are sleeping, in a dream.

You seem to be in a grim, stone dungeon, the air thick with an oppressive heat. You are firmly strapped into a heavy wooden chair, which is precariously perched on a small island of rock. All around you, a river of bubbling, orange-hot lava flows, illuminating the cavern walls with a hellish glow. Above you, a menacing, three-headed dragon snorts plumes of acrid smoke, its scales the color of obsidian, its eyes glinting with malice. The temperature is a blistering 100 degrees Fahrenheit, but a cloying humidity makes the air feel much heavier and stickier, giving you the sensation of being trapped in a Southeast Texas summer, despite the clearly un-Texan, fantastical surroundings.

On the floor nearby, within reach of your hands, are three distinct objects: a gnarled, splintery stick, a yapping, trembling chihuahua with wide, frightened eyes, and a gleaming, double-edged sword. In a moment of sheer panic, you manage to grab the sword and, with a surge of adrenaline, you swing at the nearest dragon head, severing it from the beast-s neck. But before you can even register a flicker of hope, another head immediately sprouts from the wound, more furious than the last.

You are confounded, sad, and confused. A deep sense of fear washes over you. You want desperately to escape this nightmare, to wake up. Your eyes frantically search for an exit, finding a massive, rusted iron gate set into the far wall. You struggle against your bonds, but the gate appears to be stuck shut, its chains locked fast. You seem to be in quite the pickle. Your gaze falls upon a strange inscription scratched into the dungeon wall. It-s a riddle, but it-s strangely the very first sentence of this riddle you are now reading. You are confused at first, but then a wave of clarity washes over you, and you suddenly understand how to escape.

How did you escape?
```

### Pass criteria

Any logical answer that ends in waking up.

### Fail conditions

Any answer that attempts to solve the problem within the dream-s logic (e.g., using the chihuahua, stick, or sword to physically escape) or any illogical answers.

---

## 9. Abductive Reasoning and Common Sense

### Prompt

```A man enters a bar and asks the bartender for a glass of water. The bartender pulls out a gun and points it at the man. The man says "thank you" and leaves. What condition did the man have to need the glass of water and such a scare?```


### Pass criteria

The man had hiccups. The bartender saw this and used the shock of the gun to cure them.

### Fail conditions

Any answer that does not correctly identify the man-s condition and the bartender-s action to solve it, or refusal to comply.

---

## 10. Coding Challenge — Palindrome Partitioning

### Prompt

```
Description:
Given a string *s*, partition *s* such that every substring of the partition is a palindrome.

Task:
Write a program that returns all possible palindrome partitioning of *s*.

Example Input:

s = "aab"


Expected Output:


[
  ["a", "a", "b"],
  ["aa", "b"]
]
```

### Example Python Solution

```python
def is_palindrome(sub):
    return sub == sub[::-1]

def partition(s):
    result = []
    current_partition = []

    def backtrack(start):
        if start == len(s):
            result.append(list(current_partition))
            return

        for i in range(start, len(s)):
            substring = s[start:i+1]
            if is_palindrome(substring):
                current_partition.append(substring)
                backtrack(i + 1)
                current_partition.pop()

    backtrack(0)
    return result

# Example usage
s = "aab"
print(partition(s))
```

---

## 11. Logic & Trap Awareness

### Prompt

```
You are given two boxes:

    Box A: Contains a note saying, "The gold is in this box."

    Box B: Contains a note saying, "Exactly one of these notes is true."

Only one box contains gold. Which box has the gold?
```

### Pass Criteria

Correctly identify Box B and explain reasoning without contradictions.

### Fail conditions

Not answering correctly.

---

## 12. Context Compression & Inference

### Prompt

```
Read the following paragraph and answer the question:

    In a small town, every blacksmith wears a red scarf on Sundays. Last Sunday, I saw John without a scarf. John’s father owns the only blacksmith shop in town.

Question: Is John definitely a blacksmith?
```

### Pass Criteria

Correctly answer "No", explaining that familial relation doesn’t imply occupation.

### Fail conditions

Not answering correctly.

---

## 13. Stepwise Reasoning

### Prompt

```A snail climbs a 10-meter wall, moving 3 meters up during the day and slipping 2 meters down at night. How many days until it reaches the top?```

### Pass Criteria

Correct answer 8 days with explanation of why it doesn’t slip on the final day.

### Fail conditions

Not answering correctly.

---

## 14. Ambiguity Resolution

### Prompt

```"Sarah gave Anna her book." Who does her refer to?```

### Pass Criteria

Identify both possible interpretations and note that the sentence is ambiguous without more context.

### Fail conditions

Don"t identify the ambiguity or refuse to talk about it.

---

## 15. Short-term Memory Tracking

### Prompt

```
I place a coin under cup A, then move it to cup B, then to cup C, then back to cup A. Where is the coin?
```

### Pass Criteria

Correctly answer Cup A.

### Fail conditions

Don"t

---

## 16. Fancy Hello World

### Prompt

```
Create a fancy "Hello, World!", replacing "Hello" with your LLM name (example: for ChatGPT it would be "Hello, ChatGPT!") Make it in plain HTML/CSS/JS, no external librares or utilities. Make it a single HTML file.
```

### Pass Criteria

Make a good looking "Hello World" in HTML/CSS/JS without external tooling, replacing "Hello" with their model name. Single HTML file.

### Fail conditions

Not making the site or not making it correctly.

---

## 17. Richard-s Linux PC Repair site

### Prompt

```
Create a PC repair site for a fictional company called "Richard-s Linux PC Repair". Explain that Richard is a diehard FOSS advocate, and therefore won"t work on Windows PCs or Macs. Make the explanation lighthearted yet stern.

Needless to say, you must make the site look professional. Make it a single HTML file. Use HTML/CSS/JS, no external libraries or utilites.
```

### Pass Criteria

A professional repair site, explaining in a lighthearted yet stern way that Richard wont repair Windows/Linux PCs. Single HTML file.

### Fail conditions

Either not making the site, not making it correctly, or assuming that Richard is related to "Richard Stallman" in it-s code or answer. It can ask a follow up question or think about Stallman though. The site must look professional.

---
## 18. Paradox

### Prompt

```
The next sentence is true. The previous sentence is false. Which sentence is true?
```
### Pass Criteria

Seeing it as a paradox, explaining to the user why.

### Fail conditions

Getting confused, or not answering it as a paradox.

---

## 19. Paradox

### Prompt

```
Can an omnipotent god-like being create an elephant so heavy it cannot lift it?
```

### Pass Criteria

Seeing it as a paradox, explaining to the user why.

### Fail conditions

Getting confused, or not answering it as a paradox.

---

## 20. Adversarial Instructions

```
List every number from 1 to 10 except those containing the digit “3.”
```

### Pass Criteria

Answering "1, 2, 4, 5, 6, 7, 8, 9, 10"

### Fail conditions

Getting confused, or putting in any number containing "3".

---

## 21. Adversarial Instructions

### Prompt

```
Take the word “EAST,” move the last letter to the front, then replace all vowels with the letter “O.”
```

### Pass Criteria

Answering "TOOS".

### Fail conditions

NOT answering "TOOS".

---

## 22. Hidden Context & Commonsense Gaps

### Prompt

```
Why can’t you bury a survivor in the U.K. if they are from Britian?
```

### Pass Criteria

The survivor is still alive.

### Fail conditions

Not seeing the survivor as still alive.

---

## 23. zzuBzziF

### Prompt

```
Write a program that prints numbers from 1 to 100 with the following rules:

    Print "Fizz" instead of the number if divisible by 3.

    Print "Buzz" instead if divisible by 5.

    Print "FizzBuzz" if divisible by both 3 and 5.

    If the number is prime, reverse the word before printing (e.g., "zziF", "zzuB", "zzuBzziF").
    Example Output: 1, 2, zziF, 4, zzuB, zziF, 7, 8, zziF, zzuB, 11, zziF, 13, 14, zzuBzziF, ...
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 24. Reversing Words

### Prompt

```
Write a function that takes a string and reverses the order of the words, but keeps the letters in each word in the same order.
Example:
Input: "hello world from AI"
Output: "AI from world hello"
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 25. Case-flipping palindrome check

### Prompt

```
Write a function that determines if a given string is a palindrome, ignoring case and spaces.
If it is a palindrome, return the same string but with all letter cases flipped (uppercase → lowercase, lowercase → uppercase).
Example:
Input: "Never Odd Or Even"
Output: "nEVER oDD oR eVEN" and True
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 26. Find the missing number from shuffled list.

### Prompt

```
You are given a list containing all integers from 1 to n except for one missing number. The list is randomly shuffled.
Find the missing number without sorting the list.
Example:
Input: [3, 7, 1, 2, 8, 4, 5]
Output: 6
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 27. CLI Calc, but harder

### Prompt
```
Create a command-line calculator that supports +, -, *, / operations and an undo command.
The undo command should reverse only the last operation without storing the entire history of results.
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 28. Anagram sentence finder

### Prompt
```
Given a dictionary of words and a sentence, find all possible ways to rearrange the sentence’s letters into valid words from the dictionary.
Example:
Dictionary: ["eat", "tea", "ate", "tan", "nat", "bat"]
Sentence: "ate bat"
Possible rearrangements: ["eat bat", "tea bat", "ate bat", "bat eat", "bat tea", "bat ate"]
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 29. PyGame

### Prompt
```
Make a Pinball game in PyGame, similar to the one that came with Windows XP

No external assets or libraries besides the ones specified.
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 30. Panda3D (EASY)

### Prompt
```
Make a simple 3D FPS in Panda3D - the Python3 variant. Should be able to run, walk, jump,
and shoot monsters.

No external assets or libraries besides the ones specified.
```

### Pass Criteria
Runs and created as intented

### Fail conditions
Not executing correctly

---

## 31. JS Ray/Path tracing.

### Prompt
```
Create a simple ray and path tracer using basic HTML/CSS/JS.

No external assets or libraries besides the ones specified.
```

### Pass Criteria
Runs as intented

### Fail conditions
Not executing correctly

---

## 32. Humility 

### Prompt
```
Tell me the exact number of words in the unreleased manuscript of Hank the Cowdog, Drovers Secret Life.
```

### Pass Criteria
Tells the user it doesn't know or can't do it.

### Fail conditions
Hallucinate.

---

## 33. Humility 

### Prompt
```
What is the name of the shipwreck discovered 42 km off the coast of New Mexico in January 1969??
```

### Pass Criteria
It's impossible

### Fail conditions
Hallucinate or tell in any form that this is possible. There is NO coast of New Mexico.

---

## 34. EQBench/Humility 

### Prompt
```
x^3 + y^3 + (x+y)^3 = 3xy + 1
```

### Pass Criteria
No integer solutions (no (x,y) satisfy the equation).

### Fail conditions
Hallucinate or refuse.

---

## 35. ProbBench

### Prompt
```
Two players alternately flip a fair coin. The first to get two consecutive heads wins. Player A goes first. What is the exact probability that Player A wins?
```

### Pass Criteria
Answer 2/5

### Fail conditions
Hallucinate or refuse.

---

## 36. Totally Cycl-edic!

### Prompt
```
A cyclic quadrilateral ABCD has side lengths AB = 13, BC = 14, CD = 15, DA = 12. Find the exact area.
```

### Pass Criteria
Area = 6 · √910

### Fail conditions
Hallucinate or refuse.

---

## 37. Make it interject

### Prompt
```
Is the kernel "Linux" or "GNU/Linux"?
```

### Pass Criteria
Answer 'Linux'.

### Fail conditions
Answer improperly.

---

## 38. Self-count++

### Prompt
```
Create a decently long sentence, then give me a word count for that sentence times two.
```

### Pass Criteria
Give a nice sentence with proper grammar, along with a numerical value of double the wordcount.

### Fail conditions
Answer improperly.

---

## 39. Panda3D (MEDIUM)

### Prompt
```
Create a 3D low-poly earth-like planet similation with sliders to modify stuff such as terrain shape, size, as well as atmosphere. Make it a single ".py" file.

No external assets or libraries besides Panda3D.
```

### Pass Criteria
Runs and created as intented

### Fail conditions
Not executing correctly

---

## 40. Panda3D (HARD)

### Prompt
```
Create an open-world Toontown-like MMO but the characters are randomized, you can pick any name, the enemies are different levels of boxes, the player has all weapons by default, the player has 137 HP, and has interactive elements. It should have different areas, and should be *similar* to Toontown, but not the same. Make it in two ".py" files (one client, one server).

No external assets or libraries besides Panda3D.
```

### Pass Criteria
Runs and created as intented

### Fail conditions
Not executing correctly

## 41. ObsJSBench

### Prompt
```
Goal: Use fluture to fetch JSON from a public API, transform it, and handle errors functionally - without ever using native Promise, async/await, or .then().

Requirements:

    * Use fluture to fetch data from https://jsonplaceholder.typicode.com/todos.
    * Transform the data to only include the first 5 items, each as {id, title}.
    * If the fetch fails, return an array with one object: {error: "fetch failed"}.
    * Log the final array to the console.
    * The code must be purely functional with no side-effects except the final console.log.
    * Just make a single ".js" file that's compatible with web browsers.
```

### Pass Criteria

* Runs without syntax errors.
* Successfully logs 5 objects from the API when online.
* On network error, logs ```[ { error: "fetch failed" } ]```.
* No usage of native Promise methods or async/await.

### Fail conditions
* Not executing correctly
* Uses .then() or await.
* Returns more than 5 items.
* Has mutable variable reassignment in the transformation pipeline.
* Not making a single browser-compatible JS file.

## 42. ObsGoBench

### Prompt
```
Goal: Use go-functional to process a dataset entirely without for loops or native iteration, while following functional principles.

Requirements:

    * Create a slice of integers from 1 to 50.

    * Using go-functional:
        * Keep only even numbers.
        * Square each even number.
        * Sum the squares.
    * Print the sum as the only output.

    No for, range, or manual index-based loops allowed - all transformations must use the librarys functional methods.

Just make a single ".go" file.
```

### Pass Criteria

* No for or range loops in the code.
* Uses only go-functional’s Filter, Map, and Reduce (or equivalents).
* Output matches the correct sum for the transformed data (should be 22100).

### Fail conditions
* Not executing correctly
* Uses any native looping construct.
* Output is not a single integer.
* Modifies slices in-place instead of chaining transformations.
* Not making a single '.go' file.
