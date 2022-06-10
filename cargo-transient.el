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

;; Group Names

(defvar cargo-transient--group-target-selection
  "Target Selection")
(defvar cargo-transient--group-feature-selection
  "Feature Selection")
(defvar cargo-transient--group-compilation-options
  "Compilation Options")
(defvar cargo-transient--group-manifest-options
  "Manifest Options")
(defvar cargo-transient--group-actions
  "Actions")

;; Transients

(transient-define-prefix cargo-transient ()
  "Interact with `cargo' in a transient."
  ["Commands"
   ("b" "Build" cargo-transient--build)
   ("c" "Check" cargo-transient--check)
   ("d" "Doc" cargo-transient--doc)
   ("k" "Clean" cargo-transient--clean)
   ("l" "Clippy" cargo-transient--clippy)
   ("r" "Run" cargo-transient--run)
   ("t" "Test" cargo-transient--test)])

(transient-define-prefix cargo-transient--build ()
  "Run `cargo build'."
  [cargo-transient--group-target-selection
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  [cargo-transient--group-feature-selection
   (cargo-transient--arg-features)
   (cargo-transient--arg-all-features)
   (cargo-transient--arg-no-default-features)]
  [cargo-transient--group-compilation-options
   (cargo-transient--arg-release)]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  [cargo-transient--group-actions
   ("b" "Build" cargo-transient--exec)])

(transient-define-prefix cargo-transient--check ()
  "Run `cargo check'."
  [cargo-transient--group-target-selection
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  [cargo-transient--group-feature-selection
   (cargo-transient--arg-features)
   (cargo-transient--arg-all-features)
   (cargo-transient--arg-no-default-features)]
  [cargo-transient--group-compilation-options
   (cargo-transient--arg-release)]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  [cargo-transient--group-actions
   ("c" "Check" cargo-transient--exec)])

(transient-define-prefix cargo-transient--clean ()
  "Run `cargo clean'."
  ["Clean Options"
   (cargo-transient--arg-doc
    :description "Just the documentation directory"
    :key "-d")
   (cargo-transient--arg-release
    :description "Release artifacts"
    :key "-r")]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  [cargo-transient--group-actions
   ("k" "Clean" cargo-transient--exec)])

(transient-define-prefix cargo-transient--clippy ()
  "Run `cargo clippy'."
  ["Clippy Options"
   ("-a"
    "Automatically apply lint suggestions"
    "--fix")
   ("-A"
    "Automatically apply lint suggestions, regardless of dirty or staged status"
    "--fix --allow-dirty --allow-staged")
   ("-n"
    "Run Clippy only on the given crate, without linting the dependencies"
    "--no-deps")]
  [cargo-transient--group-feature-selection
   (cargo-transient--arg-features)
   (cargo-transient--arg-all-features)
   (cargo-transient--arg-no-default-features)]
  [cargo-transient--group-target-selection
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  [cargo-transient--group-compilation-options
   (cargo-transient--arg-release)]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  [cargo-transient--group-actions
   ("l" "Clippy" cargo-transient--exec)])

(transient-define-prefix cargo-transient--doc ()
  "Run `cargo doc'."
  ["Documentation Options"
   ("-o"
    "Open the docs in a browser after builder them"
    "--open")
   ("-n"
    "Do not build documentation for dependencies"
    "--no-deps")
   ("-p"
    "Include non-public items in the documentation"
    "--document-private-items")]
  [cargo-transient--group-target-selection
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)]
  [cargo-transient--group-feature-selection
   (cargo-transient--arg-features)
   (cargo-transient--arg-all-features)
   (cargo-transient--arg-no-default-features)]
  [cargo-transient--group-compilation-options
   (cargo-transient--arg-release)]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  [cargo-transient--group-actions
   ("d" "Doc" cargo-transient--exec)])

(transient-define-prefix cargo-transient--run ()
  "Run `cargo run`."
  [cargo-transient--group-target-selection
   (cargo-transient--arg-bin)
   (cargo-transient--arg-example)]
  [cargo-transient--group-feature-selection
   (cargo-transient--arg-features)
   (cargo-transient--arg-all-features)
   (cargo-transient--arg-no-default-features)]
  [cargo-transient--group-compilation-options
   (cargo-transient--arg-release)]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  [cargo-transient--group-actions
   ("r" "Run" cargo-transient--exec)])

(transient-define-prefix cargo-transient--test ()
  "Run `cargo test'."
  ["Test Options"
   ("-c"
    "Compile, but don't run tests"
    "--no-run")
   ("-a"
    "Run all tests regardless of failure."
    "--no-fail-fast")]
  [cargo-transient--group-target-selection
   (cargo-transient--arg-bin)
   (cargo-transient--arg-bins)
   (cargo-transient--arg-doc)
   (cargo-transient--arg-example)
   (cargo-transient--arg-examples)
   (cargo-transient--arg-lib)
   (cargo-transient--arg-test)
   (cargo-transient--arg-tests)]
  [cargo-transient--group-feature-selection
   (cargo-transient--arg-features)
   (cargo-transient--arg-all-features)
   (cargo-transient--arg-no-default-features)]
  [cargo-transient--group-compilation-options
   (cargo-transient--arg-release)]
  [cargo-transient--group-manifest-options
   (cargo-transient--arg-offline)]
  ["Tests"
   (cargo-transient--arg-test-test-name)]
  [cargo-transient--group-actions
   ("t" "Test" cargo-transient--exec)])

(transient-define-argument cargo-transient--arg-test-test-name ()
  :description "Only run tests containing this string in their names"
  :class 'transient-option
  :key "-n"
  :argument "")

;; Target Selection

(transient-define-argument cargo-transient--arg-bin ()
  :description "Only the specified binary"
  :class 'transient-option
  :key "-tb"
  :argument "--bin=")

(transient-define-argument cargo-transient--arg-bins ()
  :description "All binary targets"
  :key "-tB"
  :argument "--bins")

(transient-define-argument cargo-transient--arg-doc ()
  :description "Only this library's documentation"
  :key "-td"
  :argument "--doc")

(transient-define-argument cargo-transient--arg-example ()
  :description "Only the specified example"
  :class 'transient-option
  :multi-value 'repeat
  :key "-te"
  :argument "--example=")

(transient-define-argument cargo-transient--arg-examples ()
  :description "All examples"
  :key "-tE"
  :argument "--examples")

(transient-define-argument cargo-transient--arg-lib ()
  :description "Only this package's library"
  :key "-tl"
  :argument "--lib")

(transient-define-argument cargo-transient--arg-test ()
  :description "Only the specified test target"
  :class 'transient-option
  :multi-value 'repeat
  :key "-tt"
  :argument "--test=")

(transient-define-argument cargo-transient--arg-tests ()
  :description "All tests"
  :key "-tT"
  :argument "--tests")

;; Feature Selection

(transient-define-argument cargo-transient--arg-features ()
  :description "Features"
  :class 'transient-option
  :multi-value 'repeat
  :key "-ff"
  :argument "--features=")

(transient-define-argument cargo-transient--arg-all-features ()
  :description "All available features"
  :key "-fF"
  :argument "--all-features")

(transient-define-argument cargo-transient--arg-no-default-features ()
  :description "Do not active the default features"
  :key "-fd"
  :argument "--no-default-features")

;; Compilation Options

(transient-define-argument cargo-transient--arg-release ()
  :description "Release mode, with optimizations"
  :shortarg "-cr"
  :argument "--release")

;; Manifest Options

(transient-define-argument cargo-transient--arg-offline ()
  :description "Without accessing the network"
  :key "-mo"
  :argument "--offline")

;; Private Functions

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
