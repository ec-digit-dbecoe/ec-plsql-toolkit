ALTER TABLE ds_tables MODIFY (
   batch_size CONSTRAINT ds_tab_batch_size_ck CHECK (batch_size IS NULL OR batch_size > 0)
);
