// =============================================================================
// ORY Keto Namespace Configuration
// =============================================================================
// Define your permission model using relation tuples.
//
// Namespace format:
//   namespace:object#relation@subject
//
// Example tuples:
//   files:report.txt#owner@alice
//   files:report.txt#viewer@bob
//   folders:documents#parent@files:report.txt
//
// Documentation: https://www.ory.sh/docs/keto/concepts/namespaces
// =============================================================================

import { Namespace, Context } from "@ory/keto-namespace-types"

// User namespace (subjects)
class User implements Namespace {}

// Organization namespace
class Organization implements Namespace {
  related: {
    admins: User[]
    members: User[]
  }

  permits = {
    // Admins can administer the organization
    administer: (ctx: Context): boolean =>
      this.related.admins.includes(ctx.subject),

    // Admins and members can view
    view: (ctx: Context): boolean =>
      this.permits.administer(ctx) ||
      this.related.members.includes(ctx.subject),
  }
}

// Team namespace
class Team implements Namespace {
  related: {
    organization: Organization[]
    admins: User[]
    members: User[]
  }

  permits = {
    // Team admins or org admins can administer
    administer: (ctx: Context): boolean =>
      this.related.admins.includes(ctx.subject) ||
      this.related.organization.traverse((o) => o.permits.administer(ctx)),

    // Admins, members, or org viewers can view
    view: (ctx: Context): boolean =>
      this.permits.administer(ctx) ||
      this.related.members.includes(ctx.subject) ||
      this.related.organization.traverse((o) => o.permits.view(ctx)),
  }
}

// Resource namespace (generic)
class Resource implements Namespace {
  related: {
    organization: Organization[]
    team: Team[]
    owners: User[]
    editors: User[]
    viewers: User[]
  }

  permits = {
    // Full control
    admin: (ctx: Context): boolean =>
      this.related.owners.includes(ctx.subject) ||
      this.related.organization.traverse((o) => o.permits.administer(ctx)),

    // Can edit
    write: (ctx: Context): boolean =>
      this.permits.admin(ctx) ||
      this.related.editors.includes(ctx.subject) ||
      this.related.team.traverse((t) => t.permits.administer(ctx)),

    // Can view
    read: (ctx: Context): boolean =>
      this.permits.write(ctx) ||
      this.related.viewers.includes(ctx.subject) ||
      this.related.team.traverse((t) => t.permits.view(ctx)) ||
      this.related.organization.traverse((o) => o.permits.view(ctx)),
  }
}

// Document namespace (files, reports, etc.)
class Document implements Namespace {
  related: {
    parent: Resource[]
    owners: User[]
    editors: User[]
    viewers: User[]
  }

  permits = {
    admin: (ctx: Context): boolean =>
      this.related.owners.includes(ctx.subject) ||
      this.related.parent.traverse((p) => p.permits.admin(ctx)),

    write: (ctx: Context): boolean =>
      this.permits.admin(ctx) ||
      this.related.editors.includes(ctx.subject) ||
      this.related.parent.traverse((p) => p.permits.write(ctx)),

    read: (ctx: Context): boolean =>
      this.permits.write(ctx) ||
      this.related.viewers.includes(ctx.subject) ||
      this.related.parent.traverse((p) => p.permits.read(ctx)),
  }
}

// Admin namespace (for administrative access)
class Admin implements Namespace {
  related: {
    superusers: User[]
    managers: User[]
  }

  permits = {
    // Superuser access
    superuser: (ctx: Context): boolean =>
      this.related.superusers.includes(ctx.subject),

    // Management access (includes superusers)
    access: (ctx: Context): boolean =>
      this.permits.superuser(ctx) ||
      this.related.managers.includes(ctx.subject),
  }
}
