> Template — seeds stub nodes for DevOps runbooks and operational processes.
> Each ## section → one ChromaDB node. Universal scope unless prefixed with platform.

## CI Pipeline Setup
### Theory
_Stub — pipeline stages: lint, test, build, deploy; branch rules and triggers._
### Preconditions
_Stub — required secrets, runner config, environment variables._
### Checklist
_Stub — pipeline config checklist per stage._
### Pass Criteria
_Stub — green on all branches; notifications configured._

## Deploy to Staging
### Theory
_Stub — staging deployment process; environment parity rules._
### Preconditions
_Stub — staging environment access, deployment credentials._
### Checklist
_Stub — pre-deploy checks, deploy steps, post-deploy smoke test._
### Pass Criteria
_Stub — smoke test passes; no rollback triggered._

## Deploy to Production
### Theory
_Stub — production deployment process; rollback strategy._
### Preconditions
_Stub — staging green, change approval, on-call notified._
### Checklist
_Stub — pre-deploy gate, deploy steps, post-deploy validation, rollback trigger._
### Pass Criteria
_Stub — production smoke test passes; error rate stable._

## Rollback Procedure
### Theory
_Stub — when and how to roll back a production deployment._
### Preconditions
_Stub — rollback target identified, on-call engineer available._
### Checklist
_Stub — decision criteria, rollback steps, post-rollback verification, incident log._
### Pass Criteria
_Stub — previous known-good version serving; error rate back to baseline._

## Environment Variables
### Theory
_Stub — secret vs config classification; where to store, how to inject per environment._
### Definition
_Stub — naming convention, required vs optional, rotation policy._
### Code Pattern
_Stub — canonical env var access pattern._

## Alert Triage
### Theory
_Stub — alert severity levels, first-responder steps, escalation path._
### Checklist
_Stub — acknowledge, assess impact, mitigate or escalate, communicate._
### Pass Criteria
_Stub — incident resolved or escalated within SLA._

## Incident Response
### Theory
_Stub — P1–P4 severity definitions, response SLA per level, war room process._
### Checklist
_Stub — detect → declare → mitigate → communicate → post-mortem._
### Pass Criteria
_Stub — service restored; post-mortem scheduled within 48h._

## Mobile App Release
### Theory
_Stub — App Store / Play Store release process; binary signing, staged rollout._
### Preconditions
_Stub — certificates valid, store credentials, release notes prepared._
### Checklist
_Stub — build, sign, upload, review submission, staged rollout, monitor crash rate._
### Pass Criteria
_Stub — approved in store; crash-free sessions within threshold._

## Monitoring Setup
### Theory
_Stub — observability stack: metrics, logs, traces; alert thresholds._
### Definition
_Stub — required dashboards and alert rules per service._
### Code Pattern
_Stub — canonical metric instrumentation._

## Secret Rotation
### Theory
_Stub — when and how to rotate API keys, certificates, DB credentials._
### Checklist
_Stub — identify scope, generate new, update services, revoke old, verify._
### Pass Criteria
_Stub — all services using new credentials; old credentials revoked._
