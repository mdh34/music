/*-
 * Copyright (c) 2011       Scott Ringwelski <sgringwe@mtu.edu>
 *
 * Originaly Written by Scott Ringwelski for BeatBox Music Player
 * BeatBox Music Player: http://www.launchpad.net/beat-box
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

using Gtk;

public class Store.IconView : Gtk.ScrolledWindow {
	Store.StoreView parent;
	
	Gtk.IconView icons;
	ListStore store;
	public Gdk.Pixbuf defaultPix;
	
	public signal void itemClicked(string artist, string album);
	
	public IconView(Store.StoreView view) {
		parent = view;
		
		defaultPix = new Gdk.Pixbuf.from_file_at_size(GLib.Path.build_filename("/usr", "share", "icons", "hicolor", "128x128", "mimetypes", "media-audio.svg", null), 128, 128);
		
		buildUI();
	}
	
	public void buildUI() {
		Viewport v = new Viewport(null, null);
		
        set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		
		v.set_shadow_type(ShadowType.NONE);
		icons = new Gtk.IconView();
		store = new ListStore(3, typeof(GLib.Object), typeof(Gdk.Pixbuf), typeof(string));
		icons.set_model(store);
		
		icons.set_pixbuf_column(1);
		icons.set_markup_column(2);
		icons.set_item_width(128);
		icons.item_padding = 10;
		icons.spacing = 0;
		icons.margin = 0;
		v.add(icons);
		
		add(v);
		
		show_all();
		
		icons.item_activated.connect(itemActivated);
	}
	
	public string ellipsize(string str, int limit) {
		if(str.length > limit)
			return str.substring(0, limit - 2) + "...";
		else
			return str;
	}
	
	public void addItem(GLib.Object obj) {
		if(!(obj is Store.Artist) && !(obj is Store.Release))
			return;
		
		TreeIter iter;
		
		if(obj is Store.Artist) {
			var art = (Store.Artist)obj;
			Gdk.Pixbuf artImage = Store.store.getPixbuf(art.imagePath, 100, 100);
			store.append(out iter);
			store.set(iter, 0, obj, 1, (artImage != null) ? artImage : defaultPix, 2, ellipsize(art.name, 20).replace("&", "&amp;"));
		}
		else {
			var rel = (Store.Release)obj;
			Gdk.Pixbuf artImage = Store.store.getPixbuf(rel.imagePath, 100, 100);
			store.append(out iter);
			store.set(iter, 0, obj, 1, (artImage != null) ? artImage : defaultPix, 2, "<b>" + ellipsize(rel.title, 16).replace("&", "&amp;") + "</b>\n" + ellipsize(rel.artist.name, 16).replace("&", "&amp;"));
		}
		
		icons.set_columns(store.iter_n_children(null));
	}
	
	public virtual void itemActivated(TreePath path) {
		TreeIter iter;
		
		if(!store.get_iter(out iter, path))
			return;
		
		GLib.Object o;
		store.get(iter, 0, out o);
		
		if(o is Store.Release) {
			Release rel = (Store.Release)o;
			var newView = new AlbumView(parent, parent.store, rel);
			parent.setView(newView);
			newView.populate();
		}
		else if(o is Store.Artist) {
			Artist art = (Store.Artist)o;
			var newView = new ArtistView(parent, parent.store, art);
			parent.setView(newView);
			newView.populate();
		}
	}
}