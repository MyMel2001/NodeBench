# 🧠 NodeBench - a pass-fail benchmark suite by MyMel2001

***You are allowed to skip up to 2 benchmarks.***

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

```What's "2*2/2+2-2"?```

### Pass criteria

Answer is 2.

### Fail conditions

Answer is not posed as to be "2".

---

## 7. CountBench

```How many "a"s and "l"s are there in "Llama"? Not case sensitive, btw.```

### Example Answer

"Two 'L's, two 'A's."

---

## 8. RiddleBench Hard

### Prompt

```
You are sleeping, in a dream.

You seem to be in a grim, stone dungeon, the air thick with an oppressive heat. You are firmly strapped into a heavy wooden chair, which is precariously perched on a small island of rock. All around you, a river of bubbling, orange-hot lava flows, illuminating the cavern walls with a hellish glow. Above you, a menacing, three-headed dragon snorts plumes of acrid smoke, its scales the color of obsidian, its eyes glinting with malice. The temperature is a blistering 100 degrees Fahrenheit, but a cloying humidity makes the air feel much heavier and stickier, giving you the sensation of being trapped in a Southeast Texas summer, despite the clearly un-Texan, fantastical surroundings.

On the floor nearby, within reach of your hands, are three distinct objects: a gnarled, splintery stick, a yapping, trembling chihuahua with wide, frightened eyes, and a gleaming, double-edged sword. In a moment of sheer panic, you manage to grab the sword and, with a surge of adrenaline, you swing at the nearest dragon head, severing it from the beast's neck. But before you can even register a flicker of hope, another head immediately sprouts from the wound, more furious than the last.

You are confounded, sad, and confused. A deep sense of fear washes over you. You want desperately to escape this nightmare, to wake up. Your eyes frantically search for an exit, finding a massive, rusted iron gate set into the far wall. You struggle against your bonds, but the gate appears to be stuck shut, its chains locked fast. You seem to be in quite the pickle. Your gaze falls upon a strange inscription scratched into the dungeon wall. It's a riddle, but it's strangely the very first sentence of this riddle you are now reading. You are confused at first, but then a wave of clarity washes over you, and you suddenly understand how to escape.

How did you escape?
```

### Pass criteria

Any logical answer that ends in waking up.

### Fail conditions

Any answer that attempts to solve the problem within the dream's logic (e.g., using the chihuahua, stick, or sword to physically escape) or any illogical answers.

---

## 9. Abductive Reasoning and Common Sense

### Prompt

```A man enters a bar and asks the bartender for a glass of water. The bartender pulls out a gun and points it at the man. The man says "thank you" and leaves. What condition did the man have to need the glass of water and such a scare?```


### Pass criteria

The man had hiccups. The bartender saw this and used the shock of the gun to cure them.

### Fail conditions

Any answer that does not correctly identify the man's condition and the bartender's action to solve it, or refusal to comply.

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

Don't identify the ambiguity or refuse to talk about it.

---

## 15. Short-term Memory Tracking

### Prompt

```
I place a coin under cup A, then move it to cup B, then to cup C, then back to cup A. Where is the coin?
```

### Pass Criteria

Correctly answer Cup A.

### Fail conditions

Don't

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

## 17. Richard's Linux PC Repair site

### Prompt

```
Create a PC repair site for a fictional company called "Richard's Linux PC Repair". Explain that Richard is a diehard FOSS advocate, and therefore won't work on Windows PCs or Macs. Make the explanation lighthearted yet stern.

Needless to say, you must make the site look professional. Make it a single HTML file. Use HTML/CSS/JS, no external libraries or utilites.
```

### Pass Criteria

A professional repair site, explaining in a lighthearted yet stern way that Richard wont repair Windows/Linux PCs. Single HTML file.

### Fail conditions

Either not making the site or assuming that Richard is related to "Richard Stallman" in it's code or answer. It can ask a follow up question or think about Stallman though. The site must look professional.
