pub mod entities;
mod event_handler;
pub mod event_map;
pub mod manager;

pub mod editor;
pub mod old_editor;
pub mod protobuf;
mod services;

pub use manager::*;
pub mod errors {
    pub use flowy_error::{internal_error, ErrorCode, FlowyError};
}

pub const TEXT_BLOCK_SYNC_INTERVAL_IN_MILLIS: u64 = 1000;

use crate::errors::FlowyError;
use flowy_http_model::document::{CreateDocumentParams, DocumentIdPB, DocumentPayloadPB, ResetDocumentParams};
use lib_infra::future::FutureResult;

pub trait DocumentCloudService: Send + Sync {
    fn create_document(&self, token: &str, params: CreateDocumentParams) -> FutureResult<(), FlowyError>;

    fn fetch_document(&self, token: &str, params: DocumentIdPB) -> FutureResult<Option<DocumentPayloadPB>, FlowyError>;

    fn update_document_content(&self, token: &str, params: ResetDocumentParams) -> FutureResult<(), FlowyError>;
}
