from __future__ import annotations

import re

from ansiblelint.file_utils import Lintable
from ansiblelint.rules import AnsibleLintRule


BLOCK_SCALAR_RE = re.compile(r"(^|:\s*|-\s*)([>|])([+-]?)(\d*)\s*$")


class NoBlockScalarsRule(AnsibleLintRule):
    id = 'no-block-scalars'
    shortdesc = 'YAML block scalars are forbidden'
    description = (
        'Do not use YAML block scalars (|, >, >-, etc.). '
        'Use quoted strings instead.'
    )
    severity = 'MEDIUM'
    tags = ['formatting', 'yaml']
    version_changed = '1.0.0'

    def matchlines(self, file: Lintable):
        if str(file.base_kind) != 'text/yaml':
            return []
        matches = []
        for prev_line_no, line in enumerate(file.content.splitlines()):
            stripped = line.lstrip()
            if not stripped or stripped.startswith('#'):
                continue
            if BLOCK_SCALAR_RE.search(line):
                matches.append(
                    self.create_matcherror(
                        message='YAML block scalars are forbidden; use quoted strings instead.',
                        lineno=prev_line_no + 1,
                        details=line,
                        filename=file,
                    )
                )
        return matches
