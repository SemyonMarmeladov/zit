module Main where

import Parser
import Eval

main :: IO ()
main = getLine >>= print . show . eval . readExpr
