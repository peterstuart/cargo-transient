;;; cargo-transient-tests.el --- Tests for cargo-transient -*- lexical-binding: t; -*-

;;; Commentary:

;; Unit tests for cargo-transient's command generation.

;;; Code:

(require 'cl-lib)
(require 'ert)
(require 'cargo-transient)

(defvar cargo-transient-tests--last-command nil
  "Command passed to `compile' by the most recent test invocation.")

(defvar cargo-transient-tests--last-directory nil
  "Default directory in effect when `compile' was last called.")

(defmacro cargo-transient-tests--with-mocked-cargo (workspace-manifest crate-manifest &rest body)
  "Run BODY with Cargo lookups and `compile' stubbed out.
WORKSPACE-MANIFEST is returned for `cargo locate-project --workspace'
and CRATE-MANIFEST for `cargo locate-project'."
  (declare (indent 2))
  `(let ((cargo-transient-tests--last-command nil)
         (cargo-transient-tests--last-directory nil))
     (cl-letf (((symbol-function 'shell-command-to-string)
                (lambda (command)
                  (cond ((string-match-p "locate-project --workspace" command)
                         ,workspace-manifest)
                        ((string-match-p "locate-project" command)
                         ,crate-manifest)
                        (t ""))))
               ((symbol-function 'compile)
                (lambda (command &rest _)
                  (setq cargo-transient-tests--last-command command
                        cargo-transient-tests--last-directory default-directory))))
       ,@body)))

(ert-deftest cargo-transient-tests-fmt-runs-from-crate-root ()
  "Formatting from a crate's src directory uses the crate root as cwd."
  (let ((default-directory "/project/crates/sast-engine/src/"))
    (cargo-transient-tests--with-mocked-cargo
        "/project/Cargo.toml\n" "/project/crates/sast-engine/Cargo.toml\n"
      (cargo-transient-fmt)
      (should (equal cargo-transient-tests--last-command
                     "(cd /project/crates/sast-engine/ && cargo fmt )"))
      ;; Compilation errors are still resolved relative to the workspace.
      (should (equal cargo-transient-tests--last-directory "/project/")))))

(ert-deftest cargo-transient-tests-fmt-falls-back-without-manifest ()
  "Formatting falls back to the buffer's directory if no manifest is found."
  (let ((default-directory "/project/standalone/src/"))
    (cargo-transient-tests--with-mocked-cargo "" ""
      (cargo-transient-fmt)
      (should (equal cargo-transient-tests--last-command
                     "(cd /project/standalone/src/ && cargo fmt )")))))

(ert-deftest cargo-transient-tests-other-commands-keep-cwd ()
  "Commands other than fmt still run in the invoking buffer's directory."
  (let ((default-directory "/project/crates/sast-engine/src/"))
    (cargo-transient-tests--with-mocked-cargo
        "/project/Cargo.toml\n" "/project/crates/sast-engine/Cargo.toml\n"
      (cargo-transient--exec "build")
      (should (equal cargo-transient-tests--last-command
                     "(cd /project/crates/sast-engine/src/ && cargo build )")))))

(provide 'cargo-transient-tests)

;;; cargo-transient-tests.el ends here
