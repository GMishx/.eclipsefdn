local orgs = import 'vendor/otterdog-defaults/otterdog-defaults.libsonnet';

local customRuleset(name) =
  orgs.newRepoRuleset(name) {
    enforcement: "active",
    bypass_actors+: [
      "@eclipse-sw360/technology-sw360-project-leads"
    ],
    allows_force_pushes: false,
    include_refs+: [
      "~DEFAULT_BRANCH",
    ],
    requires_linear_history: true,
    required_pull_request+: {
      required_approving_review_count: 1,
      dismisses_stale_reviews: true,
      requires_code_owner_review: true,
      requires_last_push_approval: true,
      requires_review_thread_resolution: true
    }
  };

local customDefaultBranchProtection(name) =
  orgs.newBranchProtectionRule(name) {
    pattern: name,
    requires_pull_request: true,
    required_approving_review_count: 1,
    dismisses_stale_reviews: true,
    review_dismissal_allowances+: [
      "@eclipse-sw360/technology-sw360-project-leads"
    ],
    requires_code_owner_reviews: true,
    require_last_push_approval: true,
    requires_conversation_resolution: true,
    requires_linear_history: true,
    is_admin_enforced: true,
    allows_force_pushes: false
  };

orgs.newOrg('technology.sw360', 'eclipse-sw360') {
  settings+: {
    description: "SW360 Portal Organization",
    name: "Eclipse SW360",
    workflows+: {
      actions_can_approve_pull_request_reviews: false,
    },
  },
  secrets+: [
    orgs.newOrgSecret('RENOVATE_TOKEN') {
      selected_repositories+: [
        "sw360",
        "sw360-frontend"
      ],
      value: "pass:bots/technology.sw360/github.com/renovate-token",
      visibility: "selected"
    },
    orgs.newOrgSecret('GH_PUBLISH_TOKEN') {
      selected_repositories+: [
        "sw360.website"
      ],
      value: "pass:bots/technology.sw360/github.com/website-token",
      visibility: "selected"
    }
  ],
  _repositories+:: [
    orgs.newRepo('sw360') {
      allow_auto_merge: true,
      allow_rebase_merge: true,
      allow_merge_commit: false,
      allow_squash_merge: true,
      delete_branch_on_merge: true,
      default_branch: "main",
      dependabot_security_updates_enabled: true,
      description: "SW360 project",
      has_discussions: true,
      homepage: "https://www.eclipse.org/sw360/",
      secret_scanning: "enabled",
      rulesets: [
        customRuleset("main") {
          required_status_checks+: {
            status_checks+: [
              "Build and Test"
            ]
          }
        }
      ],
      branch_protection_rules: [
        customDefaultBranchProtection("main") {
          required_status_checks+: [
            "Build and Test"
          ]
        }
      ]
    },
    orgs.newRepo('sw360-frontend') {
      allow_auto_merge: true,
      allow_rebase_merge: true,
      allow_merge_commit: false,
      allow_squash_merge: true,
      delete_branch_on_merge: true,
      default_branch: "main",
      dependabot_security_updates_enabled: true,
      description: "SW360 Frontend Project",
      homepage: "https://www.eclipse.org/sw360/",
      secret_scanning: "enabled",
      has_discussions: true,
      has_wiki: false,
      rulesets: [
        customRuleset("main") {
          required_status_checks+: {
            status_checks+: [
              "build"
            ]
          }
        }
      ],
      branch_protection_rules: [
        customDefaultBranchProtection("main") {
          required_status_checks+: [
            "build"
          ]
        }
      ]
    },
    orgs.newRepo('sw360.website') {
      allow_auto_merge: true,
      allow_rebase_merge: true,
      allow_merge_commit: false,
      allow_squash_merge: true,
      delete_branch_on_merge: true,
      default_branch: "main",
      dependabot_security_updates_enabled: true,
      description: "SW360 Website",
      has_discussions: true,
      homepage: "https://www.eclipse.org/sw360/",
      secret_scanning: "enabled",
      topics+: [
        "eclipse"
      ],
      rulesets: [
        customRuleset("main") {
          required_status_checks+: {
            status_checks+: [
              "Build and Archive"
            ]
          }
        }
      ]
    },
    orgs.newRepo('sw360.website.published') {
      allow_merge_commit: true,
      allow_update_branch: false,
      delete_branch_on_merge: false,
      workflows+: {
        enabled: false,
      },
    },
  ],
} + {
  # snippet added due to 'https://github.com/EclipseFdn/otterdog-configs/blob/main/blueprints/add-dot-github-repo.yml'
  _repositories+:: [
    orgs.newRepo('.github')
  ],
}
