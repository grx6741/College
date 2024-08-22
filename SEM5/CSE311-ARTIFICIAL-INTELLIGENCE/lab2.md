# LAB 2

## Gowrish I 2022BCS0155

Two examples of intelligent agents, besides Roomba, are Google's AlphaGo and Amazon's Alexa. Below, I'll describe each, including the problem they solve, the environment they operate in, and the properties of their respective environments.

### 1. **AlphaGo**
**Description:**  
AlphaGo is an AI agent developed by DeepMind (a subsidiary of Alphabet) that plays the board game Go. It became famous for defeating several world-class Go players, including Lee Sedol, a 9-dan professional, in 2016.

**1. Define the problem:**  
The problem AlphaGo is designed to solve is playing the game of Go at a superhuman level, specifically by evaluating the vast number of possible moves and predicting the optimal strategy to win the game.

**2. Environment specification:**
   - **State:** The board configuration, representing the position of all black and white stones.
   - **Actions:** Placing a stone on an empty intersection of the board.
   - **Percepts:** The current board state, which AlphaGo uses to evaluate possible moves.
   - **Goal:** Maximizing the difference in score between itself and the opponent, ultimately winning the game.
   - **Reward:** Positive rewards for winning, negative rewards for losing.

**3. Environment properties:**
   - **Fully Observable:** The entire board is visible to AlphaGo at all times, so it has complete information.
   - **Deterministic:** The outcome of any action (placing a stone) is fully predictable.
   - **Static:** The environment doesn’t change unless a move is made.
   - **Discrete:** Both the state of the board and the actions available are discrete.
   - **Episodic:** The game of Go has a clear beginning and end, making each game an episode.

### 2. **Amazon Alexa**
**Description:**  
Amazon Alexa is a virtual assistant AI agent designed to interact with users through voice commands, providing services such as information retrieval, smart home control, and entertainment.

**1. Define the problem:**  
Alexa's primary problem is to understand and respond appropriately to natural language voice commands, enabling it to assist users in tasks like setting alarms, controlling smart devices, answering questions, and playing music.

**2. Environment specification:**
   - **State:** The current context or situation of the user's request (e.g., time of day, recent interactions).
   - **Actions:** Generating spoken responses, executing commands, retrieving information from the internet, or controlling smart devices.
   - **Percepts:** Voice input from the user, possibly supplemented by contextual information (e.g., location, user preferences).
   - **Goal:** Accurately fulfilling the user's request in a timely and contextually appropriate manner.
   - **Reward:** User satisfaction, which may be inferred from follow-up commands, user feedback, or implicit behaviors (like not repeating the same command).

**3. Environment properties:**
   - **Partially Observable:** Alexa might not have full access to the user's intent or context beyond the spoken command.
   - **Stochastic:** User commands can be varied, ambiguous, or influenced by background noise, making the environment less predictable.
   - **Dynamic:** The environment can change unpredictably (e.g., new devices being added, different users interacting with Alexa).
   - **Continuous:** The input (voice) and the context can be continuous, with no discrete state transitions between user commands.
   - **Sequential:** Alexa often deals with a sequence of commands and interactions, where the response to one command might depend on the previous ones.
