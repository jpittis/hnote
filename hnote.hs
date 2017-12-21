module Main where

import System.Posix.Process
import Data.Time.Clock
import Data.Time.Calendar
import Text.Printf
import System.Environment
import System.FilePath.Posix
import Data.Maybe
import System.Directory
import System.Exit
import System.Process
import Control.Monad

--
-- hnote
-- Jake Pitis (jpittis)
-- version: 0.1
-- license: MIT
--
-- setup
-- -----
--
-- 1. Compile with ghc.
-- 2. Export `HNOTE_ROOT` to be the top level directory which will hold your notes.
-- 3. Notes will be stored with the path `<HNOTE_ROOT>/<category>/<yyy-mm-dd>`.
--
-- usage
-- -----
--
-- `hnote <category> - create or open a note for today in the category directory`
--
-- templates
-- ---------
--
-- If a template file by the name of `<HNOTE_ROOT>/<category>/template` is
-- found in one of your category directory, it's content will be used as the
-- initial content for newly created note.
--

defaultRoot = "./"
defaultCategory = "default"

main :: IO ()
main = do
  root <- notesRoot
  category <- categoryArg
  createCategoryIfNotPresent root category
  filename <- todayString
  let path = joinPath [root, category, filename]
  fileExists <- doesFileExist path
  when (not fileExists) $ createNote root category filename path
  executeVim path

createNote :: String -> String -> String -> String -> IO ()
createNote root category filename path = do
  callCommand $ printf "touch %s" path
  writeFile path $ noteHeader category filename
  let templatePath = joinPath [root, category, "template"]
  templateExists <- doesFileExist templatePath
  when templateExists $ callCommand (printf "cat %s >> %s" templatePath path)

executeVim :: String -> IO ()
executeVim filename =
  executeFile "vim" True [filename] Nothing

todayString :: IO String
todayString = getCurrentTime >>= return . toString . toGregorian . utctDay
  where
    toString (year, month, day) =
      printf "%d-%d-%d" year month day

notesRoot :: IO String
notesRoot = lookupEnv "HNOTE_ROOT" >>= return . fromMaybe defaultRoot

categoryArg :: IO String
categoryArg = getArgs >>= return . (\args -> if null args then defaultCategory else head args)

createCategoryIfNotPresent :: String -> String -> IO ()
createCategoryIfNotPresent root category = do
  let path = joinPath [root, category]
  exists <- doesDirectoryExist path
  prompt <- if exists then return True else promptForYesNo
  if prompt then
    createDirectoryIfMissing True category
  else
    die "Did not create new category."

promptForYesNo :: IO Bool
promptForYesNo = putStrLn "Create new category? [y/n]" >> getLine >>= return . ("y" ==)

noteHeader :: String -> String -> String
noteHeader category today =
  printf "hnote category: %s for date: %s\n" category today
