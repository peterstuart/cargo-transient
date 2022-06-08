;;; cargo-transient.el --- A transient for interacting with cargo  -*- lexical-binding: t -*-

;; Copyright (C) 2022 Peter Stuart

;; Author: Peter Stuart <peter@peterstuart.org>
;; Maintainer: Peter Stuart <peter@peterstuart.org>
;; Created: 6 Jun 2022
;; URL: https://github.com/peterstuart/cargo-transient
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see
;; <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Provides a transient for interacting with Rust's `cargo' tool.

;; See function `cargo-transient'.

;;; Code:

(require 'project)
(require 'transient)

(transient-define-prefix cargo-transient ()
  "Interact with `cargo' in a transient."
  ["Commands"
   ("b" "Build" cargo-transient--build)
   ("c" "Check" cargo-transient--check)
   ("k" "Clean" cargo-transient--clean)
   ("l" "Clippy" cargo-transient--clippy)
   ("r" "Run" cargo-transient--run)
   ("t" "Test" cargo-transient--test)])

(transient-define-prefix cargo-transient--build ()
  "Run `cargo build'."
  ["Target Selection"
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  ["Compilation Options"
   (cargo-transient--arg-release)]
  ["Manifest Options"
   (cargo-transient--arg-offline)]
  ["Actions"
   ("b" "Build" cargo-transient--exec)])

(transient-define-prefix cargo-transient--check ()
  "Run `cargo check'."
  ["Target Selection"
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  ["Compilation Options"
   (cargo-transient--arg-release)]
  ["Manifest Options"
   (cargo-transient--arg-offline)]
  ["Actions"
   ("c" "Check" cargo-transient--exec)])

(transient-define-prefix cargo-transient--clean ()
  "Run `cargo clean'."
  ["Arguments"
   (cargo-transient--arg-doc
    :description "Just the documentation directory")
   (cargo-transient--arg-offline)
   (cargo-transient--arg-release
    :description "Release artifacts")]
  ["Actions"
   ("k" "Clean" cargo-transient--exec)])

(transient-define-prefix cargo-transient--clippy ()
  "Run `cargo clippy'."
  ["Clippy Options"
   ("-f"
    "Automatically apply lint suggestions"
    "--fix")
   ("-F"
    "Automatically apply lint suggestions, regardless of dirty or staged status"
    "--fix --allow-dirty --allow-staged")
   ("-n"
    "Run Clippy only on the given crate, without linting the dependencies"
    "--no-deps")]
  ["Target Selection"
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  ["Compilation Options"
   (cargo-transient--arg-release)]
  ["Manifest Options"
   (cargo-transient--arg-offline)]
  ["Actions"
   ("l" "Clippy" cargo-transient--exec)])

(transient-define-prefix cargo-transient--run ()
  "Run `cargo run`."
  ["Target Selection"
   (cargo-transient--arg-bin)
   (cargo-transient--arg-example)]
  ["Compilation Options"
   (cargo-transient--arg-release)]
  ["Manifest Options"
   (cargo-transient--arg-offline)]
  ["Actions"
   ("r" "Run" cargo-transient--exec)])

(transient-define-prefix cargo-transient--test ()
  "Run `cargo test'."
  ["Test Options"
   ("-c"
    "Compile, but don't run tests"
    "--no-run")
   ("-f"
    "Run all tests regardless of failure."
    "--no-fail-fast")]
  ["Target Selection"
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-doc)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  ["Compilation Options"
   (cargo-transient--arg-release)]
  ["Manifest Options"
   (cargo-transient--arg-offline)]
  ["Tests"
   (cargo-transient--arg-test-test-name)]
  ["Actions"
   ("t" "Test" cargo-transient--exec)])

(transient-define-argument cargo-transient--arg-test-test-name ()
  :description "Only run tests containing this string in their names"
  :class 'transient-option
  :key "-n"
  :argument "")

;; Shared options

(transient-define-argument cargo-transient--arg-bin ()
  :description "Only the specified binary"
  :class 'transient-option
  :key "-b"
  :argument "--bin=")

(transient-define-argument cargo-transient--arg-bins ()
  :description "All binary targets"
  :key "-B"
  :argument "--bins")

(transient-define-argument cargo-transient--arg-doc ()
  :description "Only this library's documentation"
  :key "-d"
  :argument "--doc")

(transient-define-argument cargo-transient--arg-example ()
  :description "Only the specified example"
  :class 'transient-option
  :multi-value 'repeat
  :key "-e"
  :argument "--example=")

(transient-define-argument cargo-transient--arg-examples ()
  :description "All examples"
  :key "-E"
  :argument "--examples")

(transient-define-argument cargo-transient--arg-lib ()
  :description "Only this package's library"
  :key "-l"
  :argument "--lib")

(transient-define-argument cargo-transient--arg-offline ()
  :description "Without accessing the network"
  :key "-o"
  :argument "--offline")

(transient-define-argument cargo-transient--arg-release ()
  :description "Release mode, with optimizations"
  :shortarg "-r"
  :argument "--release")

(transient-define-argument cargo-transient--arg-test ()
  :description "Only the specified test target"
  :class 'transient-option
  :multi-value 'repeat
  :key "-t"
  :argument "--test=")

(transient-define-argument cargo-transient--arg-tests ()
  :description "All tests"
  :key "-T"
  :argument "--tests")

(defun cargo-transient--exec (&optional args)
  "Run `cargo' with the provided ARGS.

Uses the current transient command to determine which `cargo'
command to run."
  (interactive
   (list (transient-args transient-current-command)))
  (let* ((cargo-command
          (string-replace "cargo-transient--"
                          ""
                          (symbol-name transient-current-command)))
         (cargo-args
          (if args
              (mapconcat #'identity args " ")
            ""))
         (command
          (format "cargo %s %s" cargo-command cargo-args))
         (project (project-current))
         (default-directory
          (if project
              (project-root project)
            default-directory))
         (compilation-buffer-name-function
          (lambda (_mode) (format "*cargo %s*" cargo-command))))
    (compile command)))

(provide 'cargo-transient)

;;; cargo-transient.el ends here
