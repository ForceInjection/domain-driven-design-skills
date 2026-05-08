---
name: VN Content Creation
description: Creates visual novel dialogue content for Shadow Work including companion conversations, quest dialogues, NPC interactions, and environmental VN sequences with proper Yarn syntax and Chatterbox function integration. Use when the user asks to create dialogue, conversations, quest text, or VN sequences.
---

# VN Content Creation Skill

This skill creates visual novel dialogue content for Shadow Work with proper Yarn syntax and Chatterbox function integration.

## Content Types

### 1. Companion Dialogue
Post-recruitment conversation hubs for Canopy, Hola, or Yorna with affinity-gated content.

### 2. Quest Dialogue
Quest acceptance, progress check-ins, and completion dialogues with auto-tracking integration.

### 3. NPC Dialogue
Merchants, info givers, or story NPCs with branching conversations and inventory interactions.

### 4. VN Intro Sequence
Environmental storytelling with camera panning, portraits, and narrative delivery.

## Available Chatterbox Functions

### Inventory Functions
```yarn
<<has_item item_id quantity>>        // Returns true if player has item (quantity optional)
<<give_item item_id quantity>>       // Adds item to player inventory
<<remove_item item_id quantity>>     // Removes item from player inventory
<<inventory_count item_id>>          // Returns count of item in inventory
```

### Affinity Functions
```yarn
<<get_affinity companion_name>>      // Returns 0-10 affinity level
```

### Quest Functions
```yarn
<<quest_can_accept quest_id>>        // Returns true if quest can be accepted
<<quest_accept quest_id>>            // Accepts quest and starts tracking
<<quest_is_active quest_id>>         // Returns true if quest is active
<<quest_is_complete quest_id>>       // Returns true if quest is complete
<<objective_complete quest_id index>> // Returns true if specific objective done
<<quest_progress quest_id index>>    // Returns current progress (e.g., 3/5 kills)
```

## Template: Companion Affinity Dialogue

```yarn
title: canopy_hub
tags:
---
Canopy: Hello, friend! How can I help you?

[[Ask about training->canopy_training]]
[[Ask about backstory->canopy_backstory]]
<<if get_affinity("canopy") >= 5>>
    [[Personal question->canopy_personal]]
<<endif>>
<<if get_affinity("canopy") >= 8>>
    [[Deep conversation->canopy_deep]]
<<endif>>
[[Goodbye->canopy_goodbye]]
===

title: canopy_training
---
Canopy: I can teach you some woodland techniques!

<<if get_affinity("canopy") >= 5>>
    Canopy: Since we've grown closer, I can show you advanced moves.
    // Give advanced training
<<else>>
    Canopy: Here are the basics to get you started.
    // Give basic training
<<endif>>

[[Back->canopy_hub]]
===

title: canopy_backstory
---
Canopy: You want to know about my past?

<<if get_affinity("canopy") >= 3>>
    Canopy: Well, I suppose I can share some stories...
    Canopy: I grew up in the northern forests...
<<else>>
    Canopy: Perhaps when we know each other better.
<<endif>>

[[Back->canopy_hub]]
===

title: canopy_goodbye
---
Canopy: Safe travels!
===
```

## Template: Quest Dialogue

```yarn
title: quest_bandit_problem_start
---
Guard Captain: We've got bandits terrorizing the trade routes!

[[I'll help->accept_quest]]
[[Not interested->decline_quest]]
===

title: accept_quest
---
<<if quest_can_accept("defeat_bandits")>>
    Guard Captain: Thank you! Defeat 5 bandits and return here.
    <<quest_accept "defeat_bandits">>
    // Quest auto-tracks kill objectives
[[Back to town->town_hub]]
<<else>>
    Guard Captain: You're already helping with this!
    [[Okay->town_hub]]
<<endif>>
===

title: decline_quest
---
Guard Captain: Please reconsider - we need your help!
[[Actually, I'll help->accept_quest]]
[[Still not interested->town_hub]]
===

title: quest_bandit_problem_progress
---
<<if quest_is_complete("defeat_bandits")>>
    Guard Captain: You did it! Here's your reward.
    <<give_item "gold" 100>>
    <<give_item "health_potion" 3>>
    // Quest completion handled automatically
    [[Thanks!->town_hub]]
<<elseif quest_is_active("defeat_bandits")>>
    Guard Captain: Progress: <<quest_progress "defeat_bandits" 0>>
    // Shows "3/5 bandits defeated" etc.
    [[I'll keep hunting->town_hub]]
<<else>>
    // Quest not started yet
    [[Start quest->quest_bandit_problem_start]]
<<endif>>
===
```

## Template: Merchant NPC

```yarn
title: merchant_greeting
---
Merchant: Welcome to my shop! What can I get you?

[[Buy health potion (10 gold)->buy_health_potion]]
[[Buy arrows (5 gold per 10)->buy_arrows]]
[[Sell items->merchant_sell]]
[[Goodbye->leave_merchant]]
===

title: buy_health_potion
---
<<if has_item("gold", 10)>>
    Merchant: Here's your potion!
    <<remove_item "gold" 10>>
    <<give_item "health_potion" 1>>
    [[Thanks!->merchant_greeting]]
<<else>>
    Merchant: You need 10 gold for that.
    [[Back->merchant_greeting]]
<<endif>>
===

title: buy_arrows
---
<<if has_item("gold", 5)>>
    Merchant: Here are 10 arrows!
    <<remove_item "gold" 5>>
    <<give_item "arrow" 10>>
    [[Thanks!->merchant_greeting]]
<<else>>
    Merchant: You need 5 gold for that.
    [[Back->merchant_greeting]]
<<endif>>
===

title: merchant_sell
---
Merchant: What would you like to sell?

<<if has_item("wolf_pelt", 1)>>
    [[Sell wolf pelt (15 gold)->sell_wolf_pelt]]
<<endif>>
<<if has_item("bandit_sword", 1)>>
    [[Sell bandit sword (25 gold)->sell_bandit_sword]]
<<endif>>
[[Never mind->merchant_greeting]]
===

title: sell_wolf_pelt
---
Merchant: I'll take that pelt!
<<remove_item "wolf_pelt" 1>>
<<give_item "gold" 15>>
[[Back->merchant_greeting]]
===

title: leave_merchant
---
Merchant: Come back anytime!
===
```

## Template: VN Intro Sequence

```yarn
title: forest_intro
tags: vn_sequence
---
// Camera pans across forest landscape
The ancient forest stretches before you...

Towering trees block out the sky.

A path winds deeper into the darkness.

[[Continue->meet_canopy]]
===

title: meet_canopy
tags: vn_sequence portrait:canopy_neutral
---
// Canopy portrait appears
Canopy: Hold! Who goes there?

You: I'm just a traveler.

Canopy: These woods are dangerous for outsiders.

[[Ask for help->canopy_offers_help]]
[[I can handle myself->canopy_impressed]]
===

title: canopy_offers_help
tags: vn_sequence portrait:canopy_concerned
---
Canopy: Perhaps I could guide you?

You: That would be helpful.

Canopy: Follow me, and stay close.

// Transition to gameplay
===

title: canopy_impressed
tags: vn_sequence portrait:canopy_smiling
---
Canopy: Brave words! I like your spirit.

Canopy: Still, you'll need allies here.

[[Accept companionship->canopy_joins]]
===
```

## GML Integration Code

### Creating Dialogue Trigger Object

```gml
// obj_npc_merchant Create event
event_inherited(); // If inheriting from obj_interactable_parent

dialogue_node = "merchant_greeting";  // Starting Yarn node
sprite_index = spr_merchant;
interactable = true;
```

### Collision with Player (for dialogue start)

```gml
// obj_npc_merchant Collision with obj_player
if (keyboard_check_pressed(ord("E"))) {
    ChatterboxBegin(dialogue_node);
    // Show dialogue UI
    global.game_paused = true;
}
```

### Quest Integration Object

```gml
// obj_guard_captain Create event
event_inherited();

// Different dialogue based on quest state
if (quest_is_complete("defeat_bandits")) {
    dialogue_node = "quest_bandit_problem_progress";
} else if (quest_is_active("defeat_bandits")) {
    dialogue_node = "quest_bandit_problem_progress";
} else {
    dialogue_node = "quest_bandit_problem_start";
}
```

## Asset Requirements

### For Companion Dialogues
- Companion portrait sprites (neutral, happy, sad, angry, surprised)
- Dialogue UI background
- Text font (readable at game resolution)

### For Merchant NPCs
- NPC sprite with idle animation
- Shop UI background (if using custom shop interface)
- Item icons for buy/sell menu

### For VN Sequences
- Background images/sprites for scenes
- Portrait sprites for all speaking characters
- Camera control system (if panning)
- VN UI overlay (dialogue box, name plate)

## File Locations

### Yarn Files
Create `.yarn` files in project root or dedicated dialogue folder:
- `/dialogues/companions/canopy_hub.yarn`
- `/dialogues/quests/defeat_bandits.yarn`
- `/dialogues/npcs/merchant_general.yarn`

### Integration Objects
Create NPC objects in `/objects/`:
- `obj_npc_merchant`
- `obj_guard_captain`
- `obj_companion_canopy` (dialogue hub)

## Testing Checklist

After creating VN content:
- [ ] Test all dialogue branches are reachable
- [ ] Verify inventory functions work (has_item, give_item, remove_item)
- [ ] Test affinity gates show/hide correctly
- [ ] Verify quest functions return expected values
- [ ] Test quest acceptance and completion flows
- [ ] Check for typos and grammar errors
- [ ] Verify portraits display correctly (if used)
- [ ] Test dialogue loops don't create infinite recursion
- [ ] Verify "back" options return to correct nodes
- [ ] Test edge cases (no gold, no inventory space, etc.)

## Key Files Reference

- `/docs/DIALOGUE_FUNCTIONS.md` - Complete Chatterbox function reference
- `/docs/QUEST_SYSTEM.md` - Quest database and objective types
- `/docs/AFFINITY_SYSTEM_DESIGN.md` - Affinity mechanics and scaling
- `/docs/ITEM_INVENTORY_SYSTEM.md` - Item database and inventory structure
- `/docs/COMPANION_GUIDE.md` - Companion relationships and personalities
- `/docs/NARRATIVE_TONE_GUIDE.md` - Writing guidelines and tone

## Common Patterns

### Multi-Tier Affinity Gating
```yarn
<<if get_affinity("companion") >= 8>>
    // Deep personal content
<<elseif get_affinity("companion") >= 5>>
    // Medium personal content
<<elseif get_affinity("companion") >= 3>>
    // Light personal content
<<else>>
    // Surface-level content
<<endif>>
```

### Quest Progress Display
```yarn
<<if quest_is_active("quest_id")>>
    Current progress: <<quest_progress "quest_id" 0>>
    <<if objective_complete("quest_id", 0)>>
        First objective complete!
    <<endif>>
<<endif>>
```

### Conditional Item Requirements
```yarn
<<if has_item("quest_item", 1) and has_item("gold", 50)>>
    // Both requirements met
    <<remove_item "quest_item" 1>>
    <<remove_item "gold" 50>>
    <<give_item "reward_item" 1>>
<<else>>
    // Missing requirements
    You need: Quest Item and 50 gold
<<endif>>
```

## Important Notes

- Quest objectives auto-track through gameplay - no manual `quest_progress()` calls needed
- Affinity returns 0-10 scale (use `>= X` for tier gates)
- Always check `has_item()` before `remove_item()` to prevent negative counts
- Use `quest_can_accept()` to prevent duplicate quest acceptance
- Yarn node titles must be unique across all `.yarn` files in project
- Use descriptive node names (e.g., `canopy_training_advanced` not `node_37`)
