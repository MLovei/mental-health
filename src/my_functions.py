import os

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def replace_view(conn, view_name, view_definition):
	"""
	Replaces an existing SQLite view or creates a new one.

	This function first attempts to drop an existing view with the given name.
	If it exists, it is dropped; otherwise, no action is taken.
	Then, a new view with the specified name and definition is created.

	Args:
	    conn (sqlite3.Connection): The SQLite database connection object.
	    view_name (str): The name of the view to replace/create.
	    view_definition (str): The SQL statement defining the view
	    (e.g., "CREATE VIEW ... AS SELECT ...").
	"""
	with conn:
		cursor = conn.cursor()

		cursor.execute(f'DROP VIEW IF EXISTS {view_name}')

		cursor.execute(view_definition)
		print(f'View \'{view_name}\' replaced successfully.')

def save_dataframes_by_prefix(globals_dict, prefix, save_directory='pickles'):
	"""
	   Saves DataFrames with a specified prefix to pickle files in a designated directory.

	   This function iterates through the items in the provided globals dictionary.
	   If an item is a pandas DataFrame and its name starts with the given prefix, it is
	   saved as a pickle file in the specified directory.

	   Args:
	       globals_dict (dict): The dictionary containing global variables
	       (typically the output of `globals()`).
	       prefix (str): The prefix used to filter DataFrames for saving.
	       save_directory (str, optional): The directory to save pickle files.
	       Defaults to 'pickles'.
	   """
	os.makedirs(save_directory, exist_ok=True)
	for name, obj in globals_dict.items():
		if name.startswith(prefix) and isinstance(obj, pd.DataFrame):
			filepath = os.path.join(save_directory, f'{name}.pkl')
			obj.to_pickle(filepath)
			print(f'Saved DataFrame \'{name}\' to {filepath}')

def plot_boxplot(data, column, title,
				xlabel, ylabel, ax):
	"""
	Creates a boxplot for a specified column in a DataFrame and displays it
	on a given axis.

	Args:
		data (pandas.DataFrame): The DataFrame containing the data for the boxplot.
		column (str): The name of the column in the DataFrame used for the boxplot.
		title (str): The title to display above the boxplot.
		xlabel (str): The label for the x-axis.
		ylabel (str): The label for the y-axis.
		ax (matplotlib.axes.Axes): The axis object on which to plot the boxplot.
	"""
	sns.boxplot(y=column, data=data, ax=ax, color='red')
	ax.set_title(title)
	ax.set_xlabel(xlabel)
	ax.set_ylabel(ylabel)
	ax.tick_params(axis='y')

def plot_values(data, x_col, y_col, title, xlabel, ylabel,
				ax, rotation=0, labelsize=15):
	"""
	Creates a bar plot visualizing the relationship between a categorical
	and numerical column.

	Args:
	    data (pd.DataFrame): The DataFrame containing the data to be plotted.
	    x_col (str): The name of the column in the DataFrame to use for
	    the x-axis (categorical).
	    y_col (str): The name of the column in the DataFrame to use for
	    the y-axis (numerical).
	    title (str): The title of the plot.
	    xlabel (str): The label for the x-axis.
	    ylabel (str): The label for the y-axis.
	    ax (matplotlib.Axes): The axes object to plot onto.
	    rotation (int, optional): The rotation angle for x-axis labels (default=0).
	    labelsize (int, optional): The font size of the axis labels (default=15).

	Returns:
	    None: The function modifies the provided 'ax' object.
	"""
	sns.barplot(x=x_col, y=y_col, data=data, ax=ax, color='red')
	ax.set_title(title)
	ax.set_xlabel(xlabel)
	ax.set_ylabel(ylabel)
	ax.tick_params(axis='x', rotation=rotation, labelsize=labelsize)


def plot_stacked_bar_chart(df, variable1, variable2, series, title=None,
							xlabel=None,
							ylabel=None, legend_title=None, ax=None,
							labelsize=15):
	"""Creates a horizontal stacked bar chart to visualize aggregated data.

	This function takes a pandas DataFrame and creates a stacked bar chart to
	display the distribution of aggregated values across two categorical variables.

	Args:
	    df (pandas.DataFrame): The DataFrame containing the data to be plotted.
	    variable1 (str): The name of the first categorical column to use for grouping.
	    variable2 (str): The name of the second categorical column used to
	    create the stacks within the bars.
	    series (str, optional): The name of the column containing the values to be
	    aggregated. Defaults to 'age_count' if present in the DataFrame,
	    otherwise raises a ValueError.
	    title (str, optional): The title of the plot.
	    xlabel (str, optional): The label for the x-axis.
	    ylabel (str, optional): The label for the y-axis.
	    legend_title (str, optional): The title for the legend.
	    ax (matplotlib.Axes, optional): An existing Axes object to plot onto.
	    If not provided, a new one will be created.
	    labelsize (int, optional): The font size for the axis labels. Defaults to 15.

	Raises:
	    ValueError: If the `series` column is not found in the DataFrame
	     and 'age_count' is not present.

	Returns:
	    None: This function modifies the provided or created Axes object directly.
	"""
	values_column = series if series in df.columns else 'age_count'

	grouped_data = df.groupby([variable1, variable2])[
		values_column].sum().reset_index()
	pivot_data = grouped_data.pivot(index=variable2, columns=variable1,
									values=values_column)

	pivot_data.plot(kind='barh', stacked=True, ax=ax)

	ax.set_title(title)
	ax.set_xlabel(xlabel)
	ax.set_ylabel(ylabel)
	ax.legend(title=legend_title, loc='lower right')
	ax.tick_params(axis='x', labelsize=labelsize)
	plt.subplots_adjust(hspace=0.9)
