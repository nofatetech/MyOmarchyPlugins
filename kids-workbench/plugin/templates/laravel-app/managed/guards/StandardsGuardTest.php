<?php

// Standards guards (managed: replaced on every standards update, do not edit).
// They check project structure and forbidden patterns. They need no Laravel boot.

$root = dirname(__DIR__, 2);

test('the managed folder has its state file', function () use ($root) {
    $state = json_decode((string) @file_get_contents("$root/.kids-workbench/STATE.json"), true);
    expect($state)->toBeArray()
        ->and($state['standards'] ?? null)->toBeString()
        ->and($state['template'] ?? null)->toBeString();
});

test('AGENTS.md imports the managed base instructions', function () use ($root) {
    expect(file_exists("$root/AGENTS.md"))->toBeTrue();
    expect(file_get_contents("$root/AGENTS.md"))->toContain('@.kids-workbench/AGENTS.base.md');
});

test('BRIEF.md and PLAN.md exist', function () use ($root) {
    expect(file_exists("$root/BRIEF.md"))->toBeTrue();
    expect(file_exists("$root/PLAN.md"))->toBeTrue();
});

test('.env is git-ignored', function () use ($root) {
    $ignore = (string) @file_get_contents("$root/.gitignore");
    expect($ignore)->toMatch('/^\.env$/m');
});

test('no debug calls are left in app code', function () use ($root) {
    $hits = [];
    foreach (['app', 'routes'] as $dir) {
        if (! is_dir("$root/$dir")) {
            continue;
        }
        $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator("$root/$dir", FilesystemIterator::SKIP_DOTS));
        foreach ($files as $file) {
            if ($file->getExtension() !== 'php') {
                continue;
            }
            if (preg_match('/\b(dd|dump|var_dump|ray)\s*\(/', (string) file_get_contents($file->getPathname()))) {
                $hits[] = str_replace("$root/", '', $file->getPathname());
            }
        }
    }
    expect($hits)->toBe([]);
});
