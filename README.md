# Bussproofs in Isabelle/HOL Document Preparation

The session in this repository allows for proof trees to be included in Isabelle/HOL documents.
It defines a datatype capturing the different proof tree nodes and labels, and sets up an antiquotation that takes a term of type `('a, String.literal) prooftree` and displays it using [`bussproofs`](https://ctan.org/pkg/bussproofs).

This is meant to enable richer presentation for deeply embedded deductions within Isabelle's documents.

## Installation

- Clone the repository
- Add it as a component to your Isabelle installation, for instance using:
    ```
isabelle components -u PATH/TO/REPO
    ```

## Usage

In a text block (or any other place antiquotations can be used) use `@{prooftree TERM}` where `TERM` is the `('a, String.literal) prooftree` instance you want to display.
This antiquotation uses the same mechanism as the `value` command to evaluate that term, so it does not have to be directly a proof tree constant.

The proof tree will be drawn as a block in the centred style.

## Possible Improvements

- Allow for customising inference rule lines
- Allow for sequent-aligned proofs
- Add a constant of type `'a => ('b, String.literal) prooftree` that can be overloaded by clients and apply it to the term in the antiquotation, allowing for smoother integration with custom proof types.
