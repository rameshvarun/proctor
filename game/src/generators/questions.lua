local tablex = require('pl.tablex')
local stringx = require('pl.stringx')
local shuffle = require('src.generators.shuffle')

function generatorFromTextFile(file)
  local content, _ = love.filesystem.read(file)
  local choices = stringx.splitlines(content)
  shuffle(choices)

  return function()
    if #choices == 0 then error("Ran out of choices.") end
    return table.remove(choices, 1)
  end
end

local name, city
function resetGenerators()
  -- Generated from https://donjon.bin.sh/fantasy/name/#type=common;common=Human%20Male
  -- and https://donjon.bin.sh/fantasy/name/#type=common;common=Human%20Female
  name = generatorFromTextFile('src/generators/names.txt')

  -- Generated from https://donjon.bin.sh/fantasy/name/#type=common;common=Human%20Town
  city = generatorFromTextFile('src/generators/cities.txt')
end

local year = require "src.generators.year"


local function death()
  local answer = year()
  return {
    question = "In what year did " .. name() .. " die?",
    choices = {answer, year(), year(), year(), year()},
    answer = answer
  }
end

local function birth()
  local answer = year()
  return {
    question = "In what year was " .. name() .. " born?",
    choices = {answer, year(), year(), year(), year()},
    answer = answer
  }
end

local function cityFounded()
  local answer = year()
  return {
    question = "When was the city of " .. city() .. " founded?",
    choices = {answer, year(), year(), year(), year()},
    answer = answer
  }
end

local function capitolLocated()
  local answer = city()
  return {
    question = "Which city became the capitol in " .. year() .. "?",
    choices = {answer, city(), city(), city(), city()},
    answer = answer
  }
end

local function generalBattle()
  local answer = name()
  return {
    question = "Which general was at the battle of " .. city() .. "?",
    choices = {answer, name(), name(), name(), name()},
    answer = answer
  }
end

local function childrenRuler()
  local answer = name()
  return {
    question = "Which of " .. name() .. "'s children became the ruler of " .. city() .. "?",
    choices = {answer, name(), name(), name(), name()},
    answer = answer
  }
end

local function cityFounder()
  local answer = name()
  return {
    question = "Who founded the city of " .. city() .. "?",
    choices = {answer, name(), name(), name(), name()},
    answer = answer
  }
end

local PLAYER_TEST_SIZE = 4
assert (PLAYER_TEST_SIZE % 2 == 0, 'PLAYER_TEST_SIZE must be even.')

local OTHER_TEST_SIZE = 3

local function shuffleAnswers(question)
  shuffle(question.choices)
  return question
end

return function()
  resetGenerators()

  -- Generate a list of questions.
  local questions = {
    death(),
    birth(),
    cityFounded(),
    capitolLocated(),
    generalBattle(),
    childrenRuler(),
    cityFounder(),
  }

  -- Shuffle the questions.
  shuffle(questions)

  -- Pick out some questions for the player's test.
  local player_questions = {}
  while #player_questions < PLAYER_TEST_SIZE do
    table.insert(player_questions, table.remove(questions, 1))
  end

  -- Pick out questions from the player's test in order to put in the left and right tests.
  local left_questions, right_questions = {}, {}
  for i=1, PLAYER_TEST_SIZE/2 do
    table.insert(left_questions, tablex.deepcopy(player_questions[i]))
    table.insert(right_questions, tablex.deepcopy(player_questions[PLAYER_TEST_SIZE/2 + i]))
  end

  -- Fill up the left and right tests with the remaining questions.
  while #left_questions < OTHER_TEST_SIZE do
    table.insert(left_questions, table.remove(questions, 1))
  end
  while #right_questions < OTHER_TEST_SIZE do
    table.insert(right_questions, table.remove(questions, 1))
  end

  -- Shuffle the tests and answers.
  shuffle(player_questions); tablex.foreach(player_questions, shuffleAnswers)
  shuffle(left_questions); tablex.foreach(left_questions, shuffleAnswers)
  shuffle(right_questions); tablex.foreach(right_questions, shuffleAnswers)

  tablex.foreach(player_questions, function(q)
    q.selection = 1 end)
  tablex.foreach(left_questions, function(q)
    q.selection = tablex.find(q.choices, q.answer) end)
  tablex.foreach(right_questions, function(q)
    q.selection = tablex.find(q.choices, q.answer) end)

  return player_questions, left_questions, right_questions
end
