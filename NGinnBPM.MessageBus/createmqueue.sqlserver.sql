IF not exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[{0}]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[{0}](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[from_endpoint] [varchar](50) NOT NULL,
	[to_endpoint] [varchar](50) NOT NULL,
	[subqueue] [char](1) NOT NULL,
	[insert_time] [datetime] NOT NULL,
	[priority] [int] NOT NULL,
	[last_processed] [datetime] NULL,
	[retry_count] [int] NOT NULL,
	[retry_time] [datetime] NOT NULL,
	[error_info] [text] NULL,
	[correlation_id] [varchar](100) NULL,
	[label] [varchar](100) NULL,
	[msg_text] varchar(max) NULL,
	[msg_headers] varchar(max) null,
	[unique_id] varchar(40) null
CONSTRAINT [PK_{0}] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
) 
END

IF not exists (SELECT * FROM sys.columns c where c.object_id = OBJECT_ID(N'[dbo].[{0}]') AND c.name = N'priority')
BEGIN
alter table {0} add [priority] int not null CONSTRAINT [DF_{0}_priority] default 0 
END

IF EXISTS (SELECT * from sys.default_constraints where name = N'DF_{0}_priority')
BEGIN
ALTER TABLE [dbo].[{0}] DROP CONSTRAINT [DF_{0}_priority]
END

IF NOT EXISTS (SELECT * FROM sys.columns c, sys.indexes i, sys.index_columns ic where c.object_id = OBJECT_ID(N'[dbo].[{0}]') and i.name = N'IDX_{0}_subqueue_retry_time' and ic.index_id = i.index_id and ic.column_id = c.column_id and c.name = 'priority')
BEGIN
DROP INDEX [IDX_{0}_subqueue_retry_time] on [{0}]
END

IF NOT EXISTS (SELECT * FROM sys.indexes i where i.object_id = OBJECT_ID(N'[dbo].[{0}]') and i.name = N'IDX_{0}_subqueue_retry_time')
BEGIN
CREATE NONCLUSTERED INDEX [IDX_{0}_subqueue_retry_time] ON [dbo].[{0}] 
(
	[subqueue] ASC,
	[retry_time] ASC,
	[priority] DESC
)
INCLUDE(id)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) 
END
