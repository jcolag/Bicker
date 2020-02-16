import React from "react";
import PropTypes from "prop-types";
import PuncButton from "./PuncButton";
import ClauseSpan from "./ClauseSpan";

class Paragraph extends React.Component {
  constructor (props) {
    super(props);
  }

  choose (text, idx, pid, pnumber, offset) {
    const punct = [
      '.',
      ',',
      '!',
      '?',
      ';',
      ':',
      '(',
      ')',
      '&',
      '/',
      '&ndash;',
      '&#8212;',
      '&mdash;',
      '&#8211;',
      '&hellip;',
      '&#8230;',
    ];

    if (punct.indexOf(text) >= 0) {
      return(<PuncButton
        count={idx}
        key={idx}
        offset={offset}
        pid={pid}
        pnumber={pnumber}
        punc={text}
      />);
    } else {
      return(<ClauseSpan
        clause={text}
        count={idx}
        key={idx}
        offset={offset}
        pid={pid}
      />);
    }
  }

  paragraphParts (self, contentArray, pid, pnumber) {
    const components = [];
    const lengths = {
      '.': 1,
      ',': 1,
      '!': 1,
      '?': 1,
      ';': 1,
      ':': 1,
      '(': 1,
      ')': 1,
      '&': 1,
      '/': 1,
      '&ndash;': 2,
      '&#8212;': 2,
      '&mdash;': 3,
      '&#8211;': 3,
      '&hellip;': 3,
      '&#8230;': 3,
    };
    let length = 0;

    contentArray.map(function (c, idx) {
      const corrlen = Object.prototype.hasOwnProperty.call(lengths, c) ?
        lengths[c] : c.length;
      components.push(self.choose(c, idx, pid, pnumber, length));
      length += corrlen;
    });
    return components;
  }

  paragraphChildren(self, children, indent) {
    const result = [];

    if (
      children === null ||
      typeof children === 'undefined' ||
      children.length === 0
    ) {
      return;
    }

    children.forEach(c => result.push(<Paragraph
      avatar={c.avatar}
      beenseen={c.beenseen}
      children={c.children}
      content={c.content}
      indent={indent + 1}
      key={`child-${c.id}`}
      pid={c.id}
      pnum={c.id}
      ts={c.created_at.toString()}
      when={c.when}
      who={c.who}
    />));
    return result;
  }

  render () {
    const array = JSON.parse(this.props.content);
    const para = this.paragraphParts(
      this,
      array,
      this.props.pid,
      this.props.pnum
    );
    const indent = this.props.indent === null
      || typeof this.props.indent === 'undefined'
      ? 0
      : this.props.indent;
    const children = this.paragraphChildren(
      this,
      this.props.children,
      indent
    );
    const pad = `${indent}em`;
    const pclass = this.props.beenseen ? "msg-paragraph" : "msg-new-paragraph"
    return (
      <React.Fragment>
        <div
          style={{
            marginLeft: pad
          }}
        >
          <div className={ pclass }>
            <span
              className="msg-par-text"
            >
              { para }
            </span>
            <p className="msg-par-avatar">
              <a href='/'>
                <img draggable="false" src={ this.props.avatar } />
              </a>
              <br />
              <span className="id-time">{ this.props.who.login }</span>
              <br />
              <span
                className="id-time"
                title={ this.props.ts }
              >
                { this.props.when } ago
              </span>
            </p>
          </div>
          <div>
            { children }
          </div>
        </div>
      </React.Fragment>
    );
  }
}

Paragraph.propTypes = {
  avatar: PropTypes.string,
  beenseen: PropTypes.bool,
  count: PropTypes.number,
  indent: PropTypes.number,
  pid: PropTypes.number,
  pnum: PropTypes.number,
  ts: PropTypes.string,
  when: PropTypes.string,
  who: PropTypes.object,
};
export default Paragraph
