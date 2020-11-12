module Parser
  (
    eval,
    readExpr,
  )
where

import Control.Monad
import Text.ParserCombinators.Parsec hiding (spaces)

-- Parser combinators  ++ tree
symbol :: Parser Char
symbol = oneOf "!#$%&|*+-/:<=>?@^_~"

spaces :: Parser ()
spaces = skipMany1 space

data LispVal = Atom String
             | List [LispVal]
             | DottedList [LispVal] LispVal
             | Number Integer
             | String String
             | Bool Bool


-- TODO  parse number with  do notation and monad chaining ...
parseNumber :: Parser LispVal
parseNumber = liftM (Number . read) $ many1 digit


parseString :: Parser LispVal
parseString = do
                char '"'
                x <- many (noneOf "\"")
                char '"'
                return $ String x

parseList :: Parser LispVal
parseList = liftM List $ sepBy parseExpr spaces

parseDottedList :: Parser LispVal
parseDottedList = do
    head <- endBy parseExpr spaces
    tail <- char '.' >> spaces >> parseExpr
    return $ DottedList head tail

parseQuoted :: Parser LispVal
parseQuoted = do
    char '\''
    x <- parseExpr
    return $ List [Atom "quote", x]

-- gyah
-- Show

readValue :: LispVal -> String
readValue (Atom s) = s
readValue (Number n) = (show n)
readValue (String s) = (show s)
readValue (Bool True) = "#t"
readValue (Bool False) = "#f"
readValue (List contents) = "(" ++ unwordsList contents ++ ")"
readValue (DottedList head tail) = "(" ++ unwordsList head ++ " . " ++ readValue tail ++ ")"

unwordsList :: [LispVal] -> String
unwordsList = unwords . map readValue

instance Show LispVal where show = readValue

-- Read expresssion
parseAtom :: Parser LispVal
parseAtom = do
              first <- letter <|> symbol
              rest <- many (letter <|> digit <|> symbol)
              let atom = first:rest
              return $ case atom of
                         "#t" -> Bool True
                         "#f" -> Bool False
                         _    -> Atom atom
parseExpr :: Parser LispVal
parseExpr = parseAtom
         <|> parseString
         <|> parseNumber
         <|> parseQuoted
         <|> do char '('
                x <- try parseList <|> parseDottedList
                char ')'
                return x

eval :: LispVal -> LispVal
eval val@(String _) = val
eval val@(Number _) = val
eval val@(Bool _) = val
eval (List [Atom "quote", val]) = val

readExpr :: String -> LispVal
readExpr input = case parse parseExpr "lisp" input of
    Left err -> String $ "No match: " ++ show err
    Right val -> val