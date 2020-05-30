program bricktris;

uses
  FastMM4 in 'FastMM4.pas',
  FastMM4Messages in 'FastMM4Messages.pas',
  Forms,
  frm_main in 'frm_main.pas' {MainForm},
  bt_consts in 'bt_consts.pas',
  bt_tetrisboard in 'bt_tetrisboard.pas',
  bt_messages in 'bt_messages.pas',
  bt_hiscores in 'bt_hiscores.pas',
  bt_sha1 in 'bt_sha1.pas',
  frm_entername in 'frm_entername.pas' {EnterNameForm},
  bt_defs in 'bt_defs.pas',
  bt_utils in 'bt_utils.pas',
  frm_hiscores in 'frm_hiscores.pas' {HighScoresForm},
  frm_help in 'frm_help.pas' {HelpForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BrickTris';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
