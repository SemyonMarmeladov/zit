module Main where

import Parser

main :: IO ()
main = getLine >>= putStrLn . show . eval . readExpr
