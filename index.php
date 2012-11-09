<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title></title>
    </head>
    <body>
		<?php
			if (@$_REQUEST['doGo'])
			{
				foreach (@$_REQUEST['known'] as $k => $v)
				{
					if ($v)
						echo "Вы знаете язык $k!<br />";
					else
						echo "Вы не знаете язык $k!<br />";
				}
			}
		?>
		<form action="<?= $_SERVER['SCRIPT_NAME'] ?>" method = post>
			Какие языки программирования Вы знаете?<br />
			<input type="hidden" name="known[PHP]" value="0" />
			<input type="checkbox" name="known[PHP]" value="1" />PHP<br />
			<input type="hidden" name="known[Perl]" value="0" />
			<input type="checkbox" name="known[Perl]" value="1" />Perl<br />
			<input type="submit" name="doGo" value="Go!"/>
		</form>
		<pre>
			<?php print_r($GLOBALS); ?>
		</pre>
		<?php
			// Вывод всех переменных окружения
			foreach ($_SERVER as $k => $v)
			{
				echo "<b>$k</b> => <tt>$v</tt><br />\n";
			}
			require_once 'first.php';
			echo $create;
		?>
    </body>
</html>